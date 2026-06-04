class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_FROM", "noreply@herb-recipe-lab.com")
  layout "mailer"
end