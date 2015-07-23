$LOAD_PATH << File.dirname(__FILE__)

require 'base64'

require 'dotenv'
require 'mail'
require 'rqrcode_png'
require 'sinatra/base'
require 'slim'

Dotenv.load

class OpenMooveIt < Sinatra::Base

  Mail.defaults do
    delivery_method :smtp,
                    address:              'smtp.gmail.com',
                    port:                 '587',
                    authentication:       :plain,
                    user_name:            ENV['SMTP_USER'],
                    password:             ENV['SMTP_PASSWORD'],
                    enable_starttls_auto: true
  end

  helpers do
    def menu_entry_class(*paths)
      'active' if paths.include?(request.path_info)
    end

    def base64_encoded_code(code)
      qr = RQRCode::QRCode.new(code, size: 10, level: :h)
      png = qr.to_img
      png.resample_bilinear!(180, 180)

      Base64.encode64(png.to_blob)
    end
  end

  get '/' do
    slim :home
  end

  post '/sign_up' do
    email = params[:email]

    Mail.deliver do
      from     'open@moove-it.com'
      to       'open@moove-it.com'
      subject  'New open Moove-it inscription'
      body     email
    end

    redirect to('/')
  end

  get '/qr' do
    @code = params[:code]
    @code = 'www.moove-it.com' if !params[:code] || params[:code].empty?

    slim :qr, layout: :layout
  end

  get '/resume' do
    slim :resume
  end

  get '/projects' do
    slim :projects, layout: :layout
  end

  get '/hobbies' do
    slim :hobbies, layout: :layout
  end

end

run OpenMooveIt