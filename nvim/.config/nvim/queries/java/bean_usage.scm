((method_invocation
  object: (identifier) @bean_instance
  name: (identifier) @method_name
  arguments: (argument_list (string_literal) @arg))
  (#match? @method_name "^set[A-Z]"))
