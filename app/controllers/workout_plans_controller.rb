
class WorkoutPlansController < ApplicationController
  before_action :authenticate_user!
  before_action :find_workout_plan, only: [:show, :add_message]
  
  def index
    @workout_plans = current_user.workout_plans.order(created_at: :desc)
    
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
    # Workout plan sudah di-load di before_action
    respond_to do |format|
      format.html # Normal HTML response
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

        # Add initial chat history
        @workout_plan.add_to_chat_history('user', request_text)
        
        # Enqueue background job untuk generate actual workout plan
        GenerateWorkoutPlanJob.perform_later(@workout_plan.id, request_text)

        # Redirect langsung ke chat page menggunakan slug yang sudah ter-generate
        redirect_to workout_plan_path(@workout_plan.slug), notice: 'Generating your workout plan...'
      rescue => e
        Rails.logger.error "Failed to create workout plan: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        redirect_back(fallback_location: workout_plans_path, alert: 'Failed to generate workout plan. Please try again.')
      end
    else
      redirect_back(fallback_location: workout_plans_path, alert: 'Please enter a workout request.')
    end
  end

  def add_message
    request_text = params[:request_text]
    
    if request_text.present?
      begin
        # Add user message to history
        @workout_plan.add_to_chat_history('user', request_text)
        
        # Generate new workout plan
        new_plan = Ai::WorkoutPlannerService.new(
          user: current_user, 
          request_text: request_text,
          existing_workout_plan: @workout_plan
        ).call
        
        # Update current workout plan with new data
        @workout_plan.update!(
          title: new_plan.title,
          summary: new_plan.summary,
          focus_area: new_plan.focus_area
        )
        
        # Replace exercises
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
        
        # Delete the temporary new plan
        new_plan.destroy
        
        redirect_to workout_plan_path(@workout_plan.slug), notice: 'Workout plan updated successfully!'
      rescue => e
        Rails.logger.error "Workout plan update failed: #{e.message}"
        @workout_plan.add_to_chat_history('assistant', "Sorry, I couldn't generate a new workout plan. Please try again.")
        redirect_back(fallback_location: workout_plan_path(@workout_plan.slug), alert: 'Failed to update workout plan. Please try again.')
      end
    else
      redirect_back(fallback_location: workout_plan_path(@workout_plan.slug), alert: 'Please enter a workout request.')
    end
  end

  private

  def find_workout_plan
    slug = params[:slug]    
    @workout_plan = current_user.workout_plans.find_by!(slug: slug)
  end
end