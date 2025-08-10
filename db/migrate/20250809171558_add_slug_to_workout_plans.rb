class AddSlugToWorkoutPlans < ActiveRecord::Migration[7.1]
  def change
    add_column :workout_plans, :slug, :string
    add_index :workout_plans, :slug
    
    # Generate slugs for existing workout plans
    reversible do |dir|
      dir.up do
        WorkoutPlan.reset_column_information
        
        WorkoutPlan.find_each do |plan|
          base_text = plan.meta&.dig('request_text') || plan.title || 'workout-plan'
          
          base_slug = base_text.to_s.downcase
                              .gsub(/[^a-z0-9\s-]/, '')
                              .gsub(/\s+/, '-')
                              .gsub(/-+/, '-')
                              .strip
                              .slice(0, 50)
          
          base_slug = 'workout-plan' if base_slug.blank?
          
          counter = 1
          test_slug = base_slug
          
          while WorkoutPlan.where(user: plan.user).where(slug: test_slug).where.not(id: plan.id).exists?
            test_slug = "#{base_slug}-#{counter}"
            counter += 1
          end
          
          plan.update_column(:slug, test_slug)
        end
      end
    end
  end
end
