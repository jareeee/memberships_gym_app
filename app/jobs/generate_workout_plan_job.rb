class GenerateWorkoutPlanJob < ApplicationJob
  queue_as :default

  def perform(workout_plan_id, request_text)
    workout_plan = WorkoutPlan.find(workout_plan_id)
    user = workout_plan.user
    
    # Set meta dengan request_text
    meta = { request_text: request_text }
    
    # Generate workout plan menggunakan service
    new_plan = Ai::WorkoutPlannerService.new(
      user: current_user, 
      request_text: request_text,
      meta: meta
    ).call
    
    # Update workout plan yang sudah ada dengan data yang baru
    workout_plan.update!(
      title: new_plan.title,
      summary: new_plan.summary,
      focus_area: new_plan.focus_area,
      meta: workout_plan.meta.merge({ status: "completed" })
    )
    
    # Copy exercises dari new_plan ke workout_plan yang sudah ada
    new_plan.plan_exercises.each do |exercise|
      workout_plan.plan_exercises.create!(
        exercise: exercise.exercise,
        sets: exercise.sets,
        reps: exercise.reps,
        rest_seconds: exercise.rest_seconds,
        tempo: exercise.tempo
      )
    end
    
    # Delete temporary new plan
    new_plan.destroy
    
    # Add completion message to chat history
    workout_plan.add_to_chat_history('assistant', "✅ Your workout plan is ready! Here's your personalized #{workout_plan.title}")
    
    workout_plan.save!
  rescue => e
    Rails.logger.error "Workout plan generation job failed: #{e.message}"
    
    # Update status to failed and add error message to chat
    workout_plan = WorkoutPlan.find(workout_plan_id)
    workout_plan.update(meta: workout_plan.meta.merge({ status: "failed" }))
    workout_plan.add_to_chat_history('assistant', "❌ Sorry, I couldn't generate your workout plan. Please try again with a different request.")
  end
end
