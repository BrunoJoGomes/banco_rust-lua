local function validar_cpf(cpf)

    if #cpf ~= 11 or string.rep(cpf:sub(1,1), 11) == cpf then
        return false, "CPF inválido: formato incorreto ou números repetidos."
    end

    local soma1 = 0
    local peso = 10
    for i = 1, 9 do
        soma1 = soma1 + tonumber(cpf:sub(i,i)) * peso
        peso = peso - 1
    end
    local resto1 = soma1 % 11
    local dv1 = (resto1 < 2) and 0 or (11 - resto1)

    if dv1 ~= tonumber(cpf:sub(10,10)) then
        return false, "CPF inválido: primeiro dígito verificador incorreto."
    end

    local soma2 = 0
    local peso2 = 11
    for i = 1, 10 do
        soma2 = soma2 + tonumber(cpf:sub(i,i)) * peso2
        peso2 = peso2 - 1
    end
    local resto2 = soma2 % 11
    local dv2 = (resto2 < 2) and 0 or (11 - resto2)

    if dv2 ~= tonumber(cpf:sub(11,11)) then
        return false, "CPF inválido: segundo dígito verificador incorreto."
    end

    return true, "CPF válido."
end


function add_transform(chave, valor)
    if chave:match("^cpf_") then
        local valido, msg = validar_cpf(valor)
        if not valido then
            return false, msg
        end
        return true, valor
    elseif chave:match("^data_") then
        if not valor:match("^%d%d%d%d%-%d%d%-%d%d$") then
            return false, "Data inválida"
        end
        return true, valor
    end
    return true, valor
end


function get_transform(chave, valor)
    if chave:match("^cpf_") then
        return true, string.format("%s.%s.%s-%s", valor:sub(1,3), valor:sub(4,6), valor:sub(7,9), valor:sub(10,11))
    elseif chave:match("^data_") then
        return true, string.format("%s/%s/%s", valor:sub(9,10), valor:sub(6,7), valor:sub(1,4))
    end
    return true, valor
end
