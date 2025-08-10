#!/usr/bin/env ruby

# Script to generate slugs for existing workout plans
# Run with: bin/rails runner db/scripts/generate_slugs.rb

puts "Generating slugs for existing workout plans..."

WorkoutPlan.all.each do |plan|
  if plan.slug.blank?
    puts "Updating plan #{plan.id}: #{plan.title}"
    
    # Manually call the private method
    plan.send(:generate_slug)
    
    if plan.save
      puts "✅ Generated slug: #{plan.slug}"
    else
      puts "❌ Failed to save plan #{plan.id}: #{plan.errors.full_messages.join(', ')}"
    end
  else
    puts "✓ Plan #{plan.id} already has slug: #{plan.slug}"
  end
end

puts "\n✅ Done! All workout plans now have slugs:"
WorkoutPlan.all.each do |plan|
  puts "  - #{plan.id}: #{plan.slug}"
end
