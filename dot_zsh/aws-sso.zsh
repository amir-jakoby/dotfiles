# AWS SSO CLI shell integration
autoload -Uz +X bashcompinit && bashcompinit

__aws_sso_profile_complete() {
     local _args=${AWS_SSO_HELPER_ARGS:- -L error}
    _multi_parts : "($(/opt/homebrew/bin/aws-sso ${=_args} list --csv Profile))"
}

aws-sso-profile() {
    local _args=${AWS_SSO_HELPER_ARGS:- -L error}
    local _sso=""
    local _profile=""
    
    if [ -n "$AWS_PROFILE" ]; then
        echo "Unable to assume a role while AWS_PROFILE is set"
        return 1
    fi

    # Parse arguments
    while [ $# -gt 0 ]; do
        case "$1" in
            -S|--sso)
                shift
                if [ -z "$1" ]; then
                    echo "Error: -S/--sso requires an argument"
                    return 1
                fi
                _sso="$1"
                shift
                ;;
            -*)
                echo "Unknown option: $1"
                echo "Usage: aws-sso-profile [-S|--sso <sso-instance>] <profile>"
                return 1
                ;;
            *)
                if [ -z "$_profile" ]; then
                    _profile="$1"
                else
                    echo "Error: Multiple profiles specified"
                    return 1
                fi
                shift
                ;;
        esac
    done

    if [ -z "$_profile" ]; then
        echo "Usage: aws-sso-profile [-S|--sso <sso-instance>] <profile>"
        return 1
    fi

    # Build and execute the eval command with optional SSO flag
    if [ -n "$_sso" ]; then
        eval $(/opt/homebrew/bin/aws-sso ${=_args} -S "$_sso" eval -p "$_profile")
    else
        eval $(/opt/homebrew/bin/aws-sso ${=_args} eval -p "$_profile")
    fi
    
    if [ "$AWS_SSO_PROFILE" != "$_profile" ]; then
        return 1
    fi
}

aws-sso-clear() {
    local _args=${AWS_SSO_HELPER_ARGS:- -L error}
    if [ -z "$AWS_SSO_PROFILE" ]; then
        echo "AWS_SSO_PROFILE is not set"
        return 1
    fi
    eval $(/opt/homebrew/bin/aws-sso ${=_args} eval -c)
}

compdef __aws_sso_profile_complete aws-sso-profile
complete -C /opt/homebrew/bin/aws-sso aws-sso
