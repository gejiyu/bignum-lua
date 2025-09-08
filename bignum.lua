local bignum = {}

setmetatable(bignum, {__call = function(_, ...) return bignum.new(...) end})

local mt = {
    __add = function(num1, num2)
        return num1:add(num2)
    end,
    __sub = function(num1, num2)
        return num1:subtract(num2)
    end,
    __mul = function(num1, num2)
        return num1:multiply(num2)
    end,
    __div = function(num1, num2)
        return num1:divide(num2)
    end,
    __pow = function(num, exp)
        return num:pow(exp)
    end,
    __unm = function(num)
        return num:negate()
    end,
    __eq = function(num1, num2)
        return num1:compare(num2) == 0
    end,
    __lt = function(num1, num2)
        return num1:compare(num2) < 0
    end,
    __le = function(num1, num2)
        return num1:compare(num2) <= 0
    end,
    __tostring = function(num)
        return num:tostring()
    end,
    __index = bignum
}

local function normalize(significand, exponent)
    while math.abs(significand) >= 10 do
        significand = significand / 10
        exponent = exponent + 1
    end
    while significand ~= 0 and math.abs(significand) < 1 do
        significand = significand * 10
        exponent = exponent - 1
    end
    return significand, exponent
end

function bignum.new(significand, exponent)
    if not significand then
        significand = 0
    end
    if significand == 0 or not exponent then
        exponent = 0
    end
    significand, exponent = normalize(significand, exponent)
    return setmetatable({
        significand = significand,
        exponent = exponent
    }, mt)
end

function bignum.tostring(num)
    -- 计算实际值并格式化，避免科学计数法 (Calculate actual value and format, avoiding scientific notation)
    if num.significand == 0 then
        return "0"
    end
    
    local sign = ""
    if num.significand < 0 then
        sign = "-"
    end
    
    local abs_significand = math.abs(num.significand)
    local exponent = num.exponent
    
    -- 计算实际值 (Calculate actual value)
    local value = abs_significand * (10 ^ exponent)
    
    -- 使用 string.format 来避免科学计数法 (Use string.format to avoid scientific notation)
    if value >= 1 then
        -- 对于大于等于1的数，格式化为整数或小数
        local formatted = string.format("%.15f", value)
        -- 移除尾随的零和小数点 (Remove trailing zeros and decimal point)
        formatted = formatted:gsub("%.?0+$", "")
        return sign .. formatted
    else
        -- 对于小于1的数，使用足够的精度
        local formatted = string.format("%.15f", value)
        -- 移除尾随的零但保留必要的小数位 (Remove trailing zeros but keep necessary decimal places)
        formatted = formatted:gsub("0+$", ""):gsub("%.$", "")
        return sign .. formatted
    end
end

function bignum.clone(num)
    return bignum.new(num.significand, num.exponent)
end

function bignum.multiply(num1, num2)
    return bignum.new(
        num1.significand * num2.significand,
        num1.exponent + num2.exponent
    )
end

function bignum.divide(num1, num2)
    -- 检查除零错误 (Check for division by zero)
    if num2.significand == 0 then
        error("除零错误：不能除以零 (Division by zero error: cannot divide by zero)")
    end
    return bignum.new(
        num1.significand / num2.significand,
        num1.exponent - num2.exponent
    )
end

local function sign(num)
    if num > 0 then
        return 1
    elseif num < 0 then
        return -1
    end
    return 0
end

function bignum.compare(num1, num2)
    -- 首先比较符号 (First compare signs)
    local sign1 = sign(num1.significand)
    local sign2 = sign(num2.significand)
    
    if sign1 > sign2 then
        return 1
    elseif sign1 < sign2 then
        return -1
    end
    
    -- 符号相同，比较绝对值的大小 (Same sign, compare absolute magnitude)
    -- 计算实际的数值进行比较 (Calculate actual values for comparison)
    local exp_diff = num1.exponent - num2.exponent
    
    if exp_diff > 15 then
        -- num1 比 num2 大得多 (num1 is much larger than num2)
        return sign1
    elseif exp_diff < -15 then
        -- num2 比 num1 大得多 (num2 is much larger than num1)
        return -sign1
    else
        -- 需要精确比较 (Need precise comparison)
        local val1, val2
        if exp_diff >= 0 then
            val1 = num1.significand * (10 ^ exp_diff)
            val2 = num2.significand
        else
            val1 = num1.significand
            val2 = num2.significand * (10 ^ (-exp_diff))
        end
        
        if val1 > val2 then
            return 1
        elseif val1 < val2 then
            return -1
        else
            return 0
        end
    end
end

function bignum.add(num1, num2)
    if num1 < num2 then
        num1, num2 = num2, num1
    end
    -- 如果较小的数比较大的数小得多，直接返回较大的数 (If smaller number is much smaller, return larger number)
    -- 当指数差异大于等于5时，较小的数对结果影响很小 (When exponent difference >= 5, smaller number has minimal impact)
    if num1.exponent - num2.exponent >= 5 then
        return bignum.new(num1.significand, num1.exponent)
    end

    local significand, exponent = num2.significand, num2.exponent
    while num1.exponent ~= exponent do
        significand = significand / 10
        exponent = exponent + 1
    end
    return bignum.new(num1.significand + significand, exponent)
end

function bignum.subtract(num1, num2)
    return bignum.add(num1, num2:negate())
end

function bignum.negate(num)
    return bignum.new(-num.significand, num.exponent)
end

function bignum.abs(num)
    return bignum.new(math.abs(num.significand), num.exponent)
end

function bignum.inverse(num)
    return bignum.divide(bignum.new(1), num)
end

function bignum.pow(num, exp)
    if exp == 0 then
        return bignum.new(1)
    elseif bignum.compare(bignum.new(0), num) == 0 then
        -- 0的正数次幂为0 (0 to positive power is 0)
        if exp > 0 then
            return bignum.new(0)
        else
            error("数学错误：0的负数次幂未定义 (Math error: 0 to negative power is undefined)")
        end
    elseif exp < 0 then
        return bignum.pow(bignum.inverse(num), -exp)
    else
        -- exponent represents num's exponent
        -- exp represents the argument to pow
        local significand = num.significand
        local exponent = num.exponent
        while exp >= 2 do
            significand, exponent = normalize(significand ^ 2, exponent * 2)
            exp = exp / 2
        end
        while exp < 1 do
            significand, exponent = normalize(significand ^ 0.5, exponent * 0.5)
            exp = exp * 2
        end
        significand = significand ^ exp
        exponent = exponent * exp

        -- coerce exponent to an integer
        local decimal_part = exponent - math.floor(exponent)
        significand = significand * 10 ^ decimal_part
        exponent = exponent - decimal_part
        return bignum.new(significand, exponent)
    end
end

return bignum
