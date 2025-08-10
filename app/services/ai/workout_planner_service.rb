# frozen_string_literal: true
module Ai
  class WorkoutPlannerService
    SCHEMA = {
      type: "object",
      properties: {
        title: { type: "string" },
        focus_area: { type: "string" },
        summary: { type: "string" },
        notes: { type: "string" },
        exercises: {
          type: "array",
          items: {
            type: "object",
            properties: {
              exercise: { type: "string" },
              sets: { type: "integer" },
              reps: { type: "string" },
              rest_seconds: { type: "integer" },
              tempo: { type: "string" }
            },
            required: %w[exercise sets reps]
          }
        }
      },
      required: %w[title focus_area summary exercises]
    }.freeze

    def initialize(user:, request_text:, meta: {}, existing_workout_plan: nil)
      @user = user
      @request_text = request_text
      @meta = meta
      @existing_workout_plan = existing_workout_plan
      @model = "gpt-4o-mini"
      @client = OpenAI::Client.new
    end

    def call
      # Handle greeting tanpa memanggil LLM
      return minimal_greeting_plan if greeting?(@request_text)
      
      response = @client.chat(
        parameters: {
          model: @model,
          messages: build_messages,
          response_format: { type: "json_object" },
          temperature: 0.7,
        },
      )
      data = JSON.parse(response.dig("choices", 0, "message", "content"))

      focus_area = normalize_focus_area(data["focus_area"])

      plan = WorkoutPlan.create!(
        user: @user,
        title: data["title"],
        summary: [data["summary"], data["notes"]].compact.join("\n"),
        focus_area: focus_area,
        meta: { model: @model, raw: data, request_text: @request_text }.merge(@meta)
      )

      Array(data["exercises"]).each do |ex|
        plan.plan_exercises.create!(
          exercise: ex["exercise"],
          sets: ex["sets"],
          reps: ex["reps"],
          rest_seconds: ex["rest_seconds"],
          tempo: ex["tempo"]
        )
      end

      plan
    rescue Faraday::UnauthorizedError => e
      Rails.logger.error "OpenAI API Unauthorized: #{e.message}"
      raise "OpenAI API key invalid or expired. Please check your API key configuration."
    end

    private

    def greeting?(text)
      text.to_s.downcase.strip.match?(/\A(halo|hai|hi|hello|hey|yo)\b/)
    end

    def minimal_greeting_plan
      WorkoutPlan.create!(
        user: @user,
        title: "Hai! Yuk tentukan tujuan dulu 💪",
        summary: "Pilih fokus: upper_body, lower_body, full_body, cardio, strength, atau flexibility. Tulis juga durasi (mis. 30 menit) & lokasi (rumah/gym).",
        focus_area: "full_body",
        meta: { system: "greeting_minimal" }
      )
    end

    def normalize_focus_area(focus_area)
      return 'full_body' if focus_area.blank?
      
      case focus_area.to_s.downcase.strip
      when /upper.*body|tubuh.*atas|badan.*atas|upper/i
        'upper_body'
      when /lower.*body|tubuh.*bawah|badan.*bawah|lower|kaki|leg/i
        'lower_body'
      when /full.*body|tubuh.*penuh|seluruh.*tubuh|fullbody|whole.*body/i
        'full_body'
      when /cardio|kardio|aerobik|lari|jalan/i
        'cardio'
      when /strength|kekuatan|angkat.*beban|weight/i
        'strength'
      when /flexibility|fleksibilitas|stretching|peregangan/i
        'flexibility'
      else
        'full_body'
      end
    end

    def build_messages
      profile = {
        umur: @user.try(:age),
        sex: @user.gender,
        tinggi_cm: @user.height_cm,
        berat_kg: @user.weight_kg
      }.compact

      sys = <<~SYS
        Kamu pelatih pribadi. Rancang rencana latihan **aman** dan ringkas.
        Output **JSON** sesuai schema berikut: #{SCHEMA.to_json}.

        PENTING untuk focus_area, gunakan HANYA salah satu dari nilai berikut:
        - "upper_body" untuk latihan tubuh bagian atas
        - "lower_body" untuk latihan tubuh bagian bawah  
        - "full_body" untuk latihan seluruh tubuh
        - "cardio" untuk latihan kardiovaskular
        - "strength" untuk latihan kekuatan
        - "flexibility" untuk latihan fleksibilitas
        
        Gunakan istilah Indonesia untuk exercise, summary, dan notes. 
        Sesuaikan intensitas dengan profil. Sertakan catatan pemanasan & pendinginan di 'notes'.
        Hindari latihan berisiko untuk pemula dan jangan sebut beban spesifik (kg), cukup set/reps.
      SYS

      user_msg = <<~USR
        Profil pengguna: #{profile.to_json}
        Permintaan: #{@request_text}
        Formatkan hanya sebagai JSON valid dan tidak ada teks di luar JSON.
      USR

      [{ role: "system", content: sys }, { role: "user", content: user_msg }]
    end
  end
end
