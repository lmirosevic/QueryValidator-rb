QueryValidator
============

A simple JSON query validator for RESTful APIs written in Ruby.

Usage
------------

QueryValidator is designed for ensuring a payload a) contains all the necessary keys, b) the keys are of the correct type, and c) returns a pruned hash with only the stuff you want keyed using symbols. It supports optional fields as well as wildcard fields.

Include the module to save some typing:
```ruby
include Goonbee:QueryValidator
```

Suppose your API has a method that sends a message from one user to another located on /sendMessage and you want the client to pass along his/her authentication, target user's id, the message, a flag for whether to notify the recipient a priority, and a list of tags. A convenient way would be for the client to wrap all of those parameters into a JSON payload and send it inside a POST request:
```JSON
{
	"auth": {
		"userID": "abc123",
		"token": "12iu31b82736b"
	},
	"query": {
		"targetUserID": "def456",
		"notify": true,
		"priority": 2,
		"tags": ["greeting", "chitchat"],
		"message": "Hello dude!"
	}
}
```

Wouldn't it be nice if you could just convert that straight into a Ruby Hash that looks something like this... But raise an error in case some fields are missing or are of the wrong type?
```ruby
safe_verified_complete_hash = {
	:auth => {
		:userID => 'abc123',
		:token => '12iu31b82736b',
	},
	:query => {
		:targetUserID => 'def456',
		:notify => true,
		:priority => 2,
		:tags => ['greeting', 'chitchat'],
		:message => 'Hello dude!'
	}
}
```

With QueryValidator, all you have to do is provide that desired target payload as a template and the library will do the rest:
```ruby
raw_user_payload = ... #this is the raw user's payload

query_template = {
	:auth => {
		:userID => 'abc123',
		:token => '12iu31b82736b'
	},
	:query => {
		:targetUserID => 'def456',
		:notify => true,
		:priority => 2,
		:tags => ['greeting', 'chitchat'],
		:message => 'Hello dude!'
	}
}

safe_verified_complete_hash = Validator::process(query_template, raw_user_payload) #this will raise a `Goonbee::QueryValidator::MalformedQueryError` if the `raw_user_payload` did not match the template `query_template`.

#... use the hash with peace of mind
#eg:
sender_user_id = safe_verified_complete_hash[:auth][:userID] #this is now guaranteed to work
```

In the query template, your sample values don't have to be so long, the QueryValidator just makes sure that they are the correct type, so in practice one would do:
```ruby
raw_user_payload = ... #this is the raw user's payload

safe_verified_complete_hash = Validator::process({
	:auth => {					#hash
		:userID => '',			#string
		:token => ''			#string
	},
	:query => {					#hash
		:targetUserID => ''		#string
		:notify => true,		#boolean
		:priority => 0,			#number
		:tags => [''],			#array of string
		:message => ''			#string
	}
}, raw_user_payload) #raises error if raw query doesn't match

#...do something with the hash
```

Wildcards are supported, this one is special, so if your message is dynamic and could be many different things you would specify the value as '_':
```ruby
hash = Validator::process({
	:auth => {					#hash
		:userID => '',			#string
		:token => ''			#string
	},
	:query => {					#hash
		:targetUserID => ''		#string
		:notify => true,		#boolean
		:priority => 0,			#number
		:tags => [''],			#array of string
		:message => '_'			#anything: hash, array, string, boolean or number
	}
}, raw_user_payload)
```

Optional fields are also supported, so if tags are say optional, then you could prefix the key with an underscore, something like this:
```ruby
hash = Validator::process({
	:auth => {					#hash
		:userID => '',			#string
		:token => ''			#string
	},
	:query => {					#hash
		:targetUserID => ''		#string
		:notify => true,		#boolean
		:priority => 0,			#number
		:_tags => [''],			#optional array of string
		:message => ''			#string
	}
}, raw_user_payload)

has_tags = hash[:query].has_key?(:tags)	#N.B. the underscore is only in the query, the key in the resulting hash is `:tags`
tags = hash[:query][:tags] if has_tags
```

It's a super simple library where the focus is on representing the template query as closesly as possible to an example query. This makes the templates easy to write, maintain and read.

Dependencies
------------

* None

Copyright & License
------------

Copyright 2013 Luka Mirosevic

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this work except in compliance with the License. You may obtain a copy of the License in the LICENSE file, or at:

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.