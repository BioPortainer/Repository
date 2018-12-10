Each script should be configured in conf/runners/conf-name.json file, where conf-name is an unique name for each script. Each configuration file should contain only one script. Configuration should be a valid JSON file.

Configurable properties:

---

Each script should be configured in conf/runners/conf-name.json file, where conf-name is an unique name for each script. Each configuration file should contain only one script. Configuration should be a valid JSON file.

Examples of configuration files can be found in stable/testing/configs or see a full config at the bottom of the page.

Configurable properties:

- name
- script_path
- description
- working_directory
- allowed_users
- output_files
- requires_terminal
- bash_formatting
- parameters
	- name
	- param
	- no_value
	- description
	- required
	- constant
	- default
	- type
	- max
	- min
	- secure
	- values

# name
User-friendly script name. Will be displayed to user

Required: no </br>
Type: string </br>
Default: the filename without extension </br>
Example: "name": "My example script" </br>

# script_path
Path to the script (relative to working directory) OR just a command.

Required: yes
Type: string
Windows important: any non-batch scripts should be run as a command, e.g. 'python my_script.py'
Example: "script_path": "/some/path/to/script.sh"
Example2: "script_path": "python my_script.py"

# description
User-friendly script description, which will be shown to a user
Markdown with GitHub flavour can be used

Required: no
Type: string
Example: "description": "This script shuts down the server"

# working_directory
Working directory for the script

Required: no
Type: string
Default: script-server directory

# allowed_users
List of users, who can access the script

Required: no
Type: json array
Default: any user

# output_files
List of files, which will be downloadable by user after a script execution, can be:

- file path, with:
	- * and ** wildcard support
	- substitution of script parameters with $$$parameter_name (e.g. /home/me/$$$f1.txt, when f1=readme, become /home/me/readme.txt)
- regex pattern, for searching file path in script output:
	- should be surrounded with #
	- matching group number can be specified with number# (e.g. #2#)	
	- #any_path can be used for searching paths in the output
	- if the path cannot be found, it will be ignored
	- secure parameter values are protected with a mask during the search
	
All the matching files are copied locally and stored for at least 24 hours. Only the same user can access the files.

Required: no
Type: array
Example:

```
"output_files": [
	/* Returns the file under the path */
	"/var/log/server.log",
	
	/* Resolves param1 'value' and recursively searches for 'value'.dat in /tmp/results */
	"/tmp/results/**/$$$param1.dat",
	
	/* Searches for any paths in in the script output, and then substitutes each occurence in the path */
	"~/##any_path#/file.txt",
	
	/* Searches for any 8 digits in the script output and builds /var/log/my_8digits.log paths */
	"/var/log/my_#[0-9]{8}#.log",
	
	/* Searches for username='value' in the script output and builds /home/'value'/file.txt paths */
	"/home/#1#username=(\w+)#/file.txt"
]
```

# requires_terminal
(Linux only)
Specifies, if the script should be run in pseudo terminal mode. This is useful because some programs behave differently in terminal and non-interactive modes.

Required: no
Type: boolean
Default: true

# bash_formatting
Enables ANSI escape command parsing and showing formatted output on the user interface. E.g. \033[01;31m is a bold red text
Supported escape sequences: 16 text colors and 16 background colors, 4 text styles

Required: no
Type: boolean
Default: true for linux and mac, false otherwise

# parameters
List of script parameters. Parameters are shown on the GUI and passed to a script exactly in the same order. Below are the all allowed parameter properties

Required: no
Type: array of dicts
Example:

"parameters": [
	{
		"name": "param1",
		"param": "-a"
	},
	{
		"name": "param2",
		"param": "-b"
	}
]
##   - name
The name of the parameter, which will be shown to the user.
Required for non-constant parameters

Required: yes (for non-constant parameters)
Type: string

##  - param
Can be used for specifying flag for the parameter (e.g. -p in script.sh -p myval). If omitted, parameter will be position based

Required: no
Type: string

##   - no_value
Allows to pass only a flag to the script, without any value. param property is required in this case. This infers parameter type as boolean (the type property should be ommitted)

Required: no
Type: boolean
Default: false


##   - description
User-friendly description of the parameter, shown to the user

Required: no
Type: string

##   - required
Marks parameter as required for the user

Required: no
Type: boolean
Default: false

##   - constant
Don't show the parameter to a user, but pass it to a script with the value of default field

Required: no
Type: boolean
Default: false

##   - default
Default value shown to a user
Environment variables can be specified with $$ (e.g. "default": "$$HOME")

Required: no (for constants yes)
Type: depends on the parameter type

##   - type
Parameter type, which affects how a parameter is shown to a user (checkbox, text field, select box, etc.) and how it's passed to a script (for example as a single argument or as multiple arguments)
If no_value is set to true, then the type is ignored and always is boolean
For detail description of each type and it's supported properties see the section after properties description.

Allowed values: int, list, text, file_upload
Required: no
Type: string
Default: "text"

##   - max
Maximal allowed value

Required: no
Supported types: int
Type: string

##   - min
Mininal allowed value

Required: no
Supported types: int
Type: string

##   - secure
Don't show value on server anywhere, replace it with a mask

Required: no
Type: boolean
Default: false

##  - values
List of allowed values for the parameter. Can be either predefined values or a result from another script invocation

Required: yes (for list)
Supported types: list
Type: array or object
Example1: "values": [ "Apple", "Orange", "Banana" ]
Example2: "values": { "script": "ls /home/me/projects" }

Parameter types:

- text
Simple text field. The value is passed to a script as it is.
If parameter is secure, text field on UI will be masked.
Default value type: string

- int
The same as text, but performs number validation.
Can be constrained with min and max properties
Default value type: string or integer

- boolean (no_value)
Parameter is shown to a user as a checkbox. Since this is supported only for no_value parameters (flags only), value is not passed to a script
Default value type: boolean

- list
Provides to user a list with allowed values (as a combobox).
Allowed values should be specified with values property
Default value type: string

- file_upload
Allows user to upload a file to the server as a parameter.
The file is uploaded to the server and stored in a temp folder. Then the file is passed to a script as an absolute path
secure flag has no effect for this type
Default value type: unsupported
