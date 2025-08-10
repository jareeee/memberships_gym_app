class GenerateWorkoutPlanJob < ApplicationJob
  queue_as :default

  def perform(workout_plan_id, request_text)
    Rails.logger.info "🚀 Starting GenerateWorkoutPlanJob for workout_plan_id: #{workout_plan_id}"
    
    workout_plan = WorkoutPlan.find(workout_plan_id)
    user = workout_plan.user
    
    Rails.logger.info "📝 Current workout plan title: #{workout_plan.title}"
    
    # Set meta dengan request_text
    meta = { request_text: request_text }
    
    # Generate workout plan menggunakan service
    Rails.logger.info "🤖 Calling AI service..."
    new_plan = Ai::WorkoutPlannerService.new(
      user: user, 
      request_text: request_text,
      meta: meta
    ).call
    
    Rails.logger.info "✅ AI service returned new plan: #{new_plan.title}"
    
    # Update workout plan yang sudah ada dengan data yang baru
    Rails.logger.info "🔄 Updating existing workout plan..."
    workout_plan.update!(
      title: new_plan.title,
      summary: new_plan.summary,
      focus_area: new_plan.focus_area,
      meta: workout_plan.meta.merge({ status: "completed" })
    )
    
    Rails.logger.info "📊 Updated workout plan title to: #{workout_plan.reload.title}"
    
    # Copy exercises dari new_plan ke workout_plan yang sudah ada
    Rails.logger.info "💪 Copying #{new_plan.plan_exercises.count} exercises..."
    new_plan.plan_exercises.each do |exercise|
      workout_plan.plan_exercises.create!(
        exercise: exercise.exercise,
        sets: exercise.sets,
        reps: exercise.reps,
        rest_seconds: exercise.rest_seconds,
        tempo: exercise.tempo
      )
    end
    
    Rails.logger.info "📈 Workout plan now has #{workout_plan.plan_exercises.count} exercises"
    
    # Delete temporary new plan
    new_plan.destroy
    
    # Add completion message to chat history
    workout_plan.add_to_chat_history('assistant', "✅ Your workout plan is ready! Here's your personalized #{workout_plan.title}")
    
    workout_plan.save!
    
    Rails.logger.info "🎉 GenerateWorkoutPlanJob completed successfully!"
  rescue => e
    Rails.logger.error "❌ Workout plan generation job failed: #{e.message}"
    Rails.logger.error "📍 Backtrace: #{e.backtrace.first(5).join("\n")}"

    begin
      workout_plan = WorkoutPlan.find(workout_plan_id)
      workout_plan.update(meta: workout_plan.meta.merge({ status: "failed" }))
      workout_plan.add_to_chat_history('assistant', "❌ Sorry, I couldn't generate your workout plan. Please try again with a different request.")
      Rails.logger.info "💾 Updated workout plan status to failed"
    rescue => rescue_error
      Rails.logger.error "🆘 Failed to update workout plan with error status: #{rescue_error.message}"
    end
  end
end
