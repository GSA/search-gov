# NOTE: This is a 1.9.3 backport based on this gist: https://gist.github.com/2cdc187fa0c7b608fe2c
#   Once we move to 1.9.3, we should delete this file.
module Net
  def HTTP.start(address, *arg, &block) # :yield: +http+
    arg.pop if opt = Hash.try_convert(arg[-1])
    port, p_addr, p_port, p_user, p_pass = *arg
    port = https_default_port if !port && opt && opt[:use_ssl]
    http = new(address, port, p_addr, p_port, p_user, p_pass)

    if opt
      opt = {:verify_mode => OpenSSL::SSL::VERIFY_NONE}.update(opt) if opt[:use_ssl]
      http.methods.grep(/\A(\w+)=\z/) do |meth|
        key = $1.to_sym
        opt.key?(key) or next
        http.__send__(meth, opt[key])
      end
    end

    http.start(&block)
  end
end