require "./netinet/in"
require "./sys/socket"
require "./stdint"

lib LibC
  struct Addrinfo
    ai_flags : Int
    ai_family : Int
    ai_socktype : Int
    ai_protocol : Int
    ai_addrlen : SocklenT
    ai_canonname : Char*
    ai_addr : Void*
    ai_next : Addrinfo*
  end

  fun gai_strerror(x0 : Int) : Char*
end
