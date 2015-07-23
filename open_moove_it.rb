require 'base64'

require 'sinatra/base'
require 'slim'
require 'rqrcode_png'
require 'mail'

class OpenMooveIt < Sinatra::Base

  Mail.defaults do
    delivery_method :smtp,
                    address:              'smtp.gmail.com',
                    port:                 '587',
                    authentication:       :plain,
                    user_name:            'admin@moove-it.com',
                    password:             'Moo1729IT',
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
    @code = params[:code] || 'www.moove-it.com'

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