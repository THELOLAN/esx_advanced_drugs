locales = locales or {}
-- Leaked By: Leaking Hub | J. Snow | leakinghub.com
function getLocalizedText(text, ...)
    local message = locales[config.locale][text]
    
    return string.format(message, ...)
end