# encoding: UTF-8

# query_validator.rb
# Goonbee
#
# Created by Luka Mirosevic on 27/04/2013.
# Copyright (c) 2013 Goonbee. All rights reserved.

#foo sanitize string input

module Goonbee
	module QueryValidator
		class Validator
			class << self
				def type(obj)
					case obj
						when String
							return :str
						when Fixnum, Float, Bignum
							return :num
						when Hash
							return :hash
						when Array
							return :array
						when TrueClass, FalseClass
							return :bool
						when :_
							return :any
						else
							return nil
					end
				end

				def process(a, b)
					if type(a) == :any
						b
					elsif type(a) == :str && type(b) == :str
						b
					elsif type(a) == :num && type(b) == :num
						b
					elsif type(a) == :bool && type(b) == :bool
						b
					elsif type(a) == :array && type(b) == :array
						b.map {|i| process(a[0], i)}
					elsif type(a) == :hash && type(b) == :hash
						new_hash = Hash.new

						a.each_key do |key|
							if key[0] == '_'#optional key
								search_key_s = key[1..-1]
								search_key_sym = search_key_s.to_sym#this one is safe because it comes from our finite set query

								optional = true
							else#required key
								search_key_s = key.to_s
								search_key_sym = key

								optional = false
							end

							if b.has_key?(search_key_s)#has string?
								new_hash[search_key_sym] = process(a[key], b[search_key_s])
							elsif b.has_key?(search_key_sym)#has symbol?
								new_hash[search_key_sym] = process(a[key], b[search_key_sym])
							else
								raise 'Doesn\'t match' unless optional
							end
						end

						return new_hash
					else
						raise 'Doesn\'t match'
					end
				end
			end
		end
	end
end