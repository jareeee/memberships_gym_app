class GenerateWorkoutPlanJob < ApplicationJob
  queue_as :default

  def perform(workout_plan_id, request_text)
    workout_plan = WorkoutPlan.find(workout_plan_id)
    user = workout_plan.user

    meta = { request_text: request_text }

    new_plan = Ai::WorkoutPlannerService.new(
      user: user, 
      request_text: request_text,
      meta: meta
    ).call

    workout_plan.update!(
      title: new_plan.title,
      summary: new_plan.summary,
      focus_area: new_plan.focus_area,
      meta: workout_plan.meta.merge({ status: "completed" })
    )

    new_plan.plan_exercises.each do |exercise|
      workout_plan.plan_exercises.create!(
        exercise: exercise.exercise,
        sets: exercise.sets,
        reps: exercise.reps,
        rest_seconds: exercise.rest_seconds,
        tempo: exercise.tempo
      )
    end

    new_plan.destroy
    workout_plan.save!
  end
end
