
class WorkoutPlansController < ApplicationController
  before_action :authenticate_user!
  before_action :check_membership_and_profile, except: [:index]
  before_action :find_workout_plan, only: [:show, :add_message]
  before_action :ensure_ai_limit_available, only: [:create, :add_message]

  def index
    @per_page = 5
    @page = params[:page].to_i
    @page = 1 if @page < 1

    base_scope = current_user.workout_plans.order(created_at: :desc)
    @total_count = base_scope.count
    @total_pages = (@total_count.to_f / @per_page).ceil
    @workout_plans = base_scope.limit(@per_page).offset((@page - 1) * @per_page)

    all_suggestions = [
      "Upper body workout at home 30 minutes",
      "Lower body strength training",
      "Full body cardio workout",
      "Beginner flexibility routine",
      "Core workout 20 minutes",
      "Push - pull split 3 days",
      "Dumbbell only upper body",
      "HIIT 15 minutes",
    ]

    @quick_suggestions = all_suggestions.sample(3)
  end

  def show
    respond_to do |format|
      format.html
      format.json { 
        render json: { 
          status: @workout_plan.meta&.dig('status') || 'unknown',
          title: @workout_plan.title,
          exercises_count: @workout_plan.plan_exercises.count,
          updated_at: @workout_plan.updated_at.iso8601
        }
      }
    end
  end

  def create
    request_text = params[:request_text]

    if request_text.present?
      begin
        @workout_plan = current_user.workout_plans.create!(
          title: "Generating workout plan...",
          summary: "Your workout plan is being generated. Please wait.",
          focus_area: "full_body",
          meta: { 
            request_text: request_text,
            status: "generating"
          }
        )

        @workout_plan.reload

        if @workout_plan.slug.blank?
          @workout_plan.send(:generate_slug)
          @workout_plan.save!
          @workout_plan.reload
        end

        @workout_plan.add_to_chat_history('user', request_text)

        current_user.increment_ai_usage!

        GenerateWorkoutPlanJob.perform_later(@workout_plan.id, request_text)

        redirect_to workout_plan_path(@workout_plan.slug)
      rescue => e
        Rails.logger.error "Failed to create workout plan: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        redirect_back(fallback_location: workout_plans_path)
      end
    else
      redirect_back(fallback_location: workout_plans_path)
    end
  end

  def add_message
    request_text = params[:request_text]

    if request_text.present?
      begin
        @workout_plan.add_to_chat_history('user', request_text)

        current_user.increment_ai_usage!

        new_plan = Ai::WorkoutPlannerService.new(
          user: current_user, 
          request_text: request_text,
          existing_workout_plan: @workout_plan
        ).call

        @workout_plan.update!(
          title: new_plan.title,
          summary: new_plan.summary,
          focus_area: new_plan.focus_area
        )

        @workout_plan.plan_exercises.destroy_all
        new_plan.plan_exercises.each do |exercise|
          @workout_plan.plan_exercises.create!(
            exercise: exercise.exercise,
            sets: exercise.sets,
            reps: exercise.reps,
            rest_seconds: exercise.rest_seconds,
            tempo: exercise.tempo
          )
        end

        new_plan.destroy

        redirect_to workout_plan_path(@workout_plan.slug)
      rescue => e
        Rails.logger.error "Workout plan update failed: #{e.message}"
        @workout_plan.add_to_chat_history('assistant', "Sorry, I couldn't generate a new workout plan. Please try again.")
        redirect_back(fallback_location: workout_plan_path(@workout_plan.slug))
      end
    else
      redirect_back(fallback_location: workout_plan_path(@workout_plan.slug))
    end
  end

  private

  def check_membership_and_profile
    unless current_user.has_active_membership?
      redirect_to memberships_path, alert: '🔒 AI Workout Plans memerlukan membership aktif. Silakan berlangganan terlebih dahulu!'
      return
    end

    unless profile_complete?
      redirect_to edit_profile_path, alert: '📝 Untuk menggunakan AI Workout Plans, lengkapi profile Anda terlebih dahulu (tanggal lahir, jenis kelamin, tinggi, dan berat badan).'
      return
    end
  end

  def profile_complete?
    current_user.birthdate.present? &&
    current_user.gender.present? &&
    current_user.height_cm.present? &&
    current_user.weight_kg.present?
  end

  def find_workout_plan
    slug = params[:slug]    
    @workout_plan = current_user.workout_plans.find_by!(slug: slug)
  end

  def ensure_ai_limit_available
    current_user.ensure_ai_weekly_period!
    return if current_user.ai_usage_allowed?

    remaining_date = current_user.monday_for(Date.current + 7)
    message = "🔒 Batas penggunaan AI mingguan Anda telah habis (#{User::WEEKLY_AI_LIMIT}x). Kuota akan direset setiap hari Senin."

    fallback = if defined?(@workout_plan) && @workout_plan.present?
                 workout_plan_path(@workout_plan.slug)
               else
                 workout_plans_path
               end

    redirect_back(fallback_location: fallback, alert: message)
  end
end
