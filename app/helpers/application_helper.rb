module ApplicationHelper
	def user_initials(user)
		return "?" unless user

		name = user.full_name.to_s.strip
		if name.present?
			parts = name.split(/\s+/)
			initials = String.new
			initials << parts[0][0].to_s if parts[0]
			initials << parts[1][0].to_s if parts[1]
			return initials.upcase
		end

		email = user.email.to_s
		email.present? ? email[0].upcase : "?"
	end

	def user_display_name(user)
		return "User" unless user
		user.full_name.presence || user.email.presence || "User"
	end

	def user_avatar_url(user)
		return nil unless user

		if user.respond_to?(:avatar_url) && user.avatar_url.present?
			return user.avatar_url
		end

		if user.respond_to?(:avatar) && user.avatar.respond_to?(:attached?) && user.avatar.attached?
			return url_for(user.avatar)
		end
	end

	def avatar_for(user, size: 32, classes: "")
		url = user_avatar_url(user)
		size_class = "w-[#{size}px] h-[#{size}px]"
		if url
			image_tag(url, alt: user_display_name(user), class: [size_class, "rounded-full object-cover", classes].join(" ").strip)
		else
			content_tag(:div, user_initials(user), class: [size_class, "rounded-full flex items-center justify-center bg-gray-300 text-gray-800 font-semibold text-[12px]", classes].join(" ").strip)
		end
	end
end
