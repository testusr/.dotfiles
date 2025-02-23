((class_declaration
     name: (identifier) @class_name
       body: (class_body
                   (field_declaration
                           (modifiers (marker_annotation)* "private") @private_field
                                 (variable_declarator name: (identifier) @field_name))
                       (method_declaration
                               (modifiers (marker_annotation)* "public")
                                     name: (identifier) @getter_name
                                           parameters: (formal_parameters)
                                                 body: (block (return_statement (_) @field_ref)))
                           (method_declaration
                                   (modifiers (marker_annotation)* "public")
                                         name: (identifier) @setter_name
                                               parameters: (formal_parameters (formal_parameter name: (identifier) @param_name))
                                                     body: (block (expression_statement (assignment_expression left: (_) right: (_)))))
                               (#match? @getter_name "^(get|is)[A-Z]")
                                   (#match? @setter_name "^set[A-Za-z]")
                                       (#eq? @field_ref @field_name)
                                       (#eq? @param_name @field_name))) @bean_class)

