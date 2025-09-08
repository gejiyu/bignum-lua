-- 大数库测试文件 (Bignum Library Test File)
-- 测试 bignum.lua 的各种功能和边界情况 (Test various functions and edge cases of bignum.lua)

local bignum = require("bignum")

-- 测试辅助函数 (Test helper functions)
local function assert_equal(actual, expected, message)
    if actual ~= expected then
        error(string.format("断言失败 (Assertion failed): %s\n期望 (Expected): %s\n实际 (Actual): %s", 
              message or "", tostring(expected), tostring(actual)))
    end
end

local function assert_bignum_equal(actual, expected, message)
    if bignum.compare(actual, expected) ~= 0 then
        error(string.format("大数断言失败 (Bignum assertion failed): %s\n期望 (Expected): %s\n实际 (Actual): %s", 
              message or "", tostring(expected), tostring(actual)))
    end
end

local function run_test(test_name, test_func)
    print("运行测试 (Running test): " .. test_name)
    local success, error_msg = pcall(test_func)
    if success then
        print("✓ 测试通过 (Test passed): " .. test_name)
    else
        print("✗ 测试失败 (Test failed): " .. test_name)
        print("错误信息 (Error message): " .. error_msg)
        error("测试失败 (Test failed)")
    end
end

-- 基本构造函数测试 (Basic constructor tests)
local function test_constructor()
    -- 测试默认构造函数 (Test default constructor)
    local zero = bignum.new()
    assert_bignum_equal(zero, bignum.new(0, 0), "默认构造应该创建零 (Default constructor should create zero)")
    
    -- 测试单参数构造函数 (Test single parameter constructor)
    local one = bignum.new(1)
    assert_bignum_equal(one, bignum.new(1, 0), "单参数构造应该设置指数为0 (Single parameter should set exponent to 0)")
    
    -- 测试双参数构造函数 (Test two parameter constructor)
    local big = bignum.new(1.5, 10)
    assert_equal(big.significand, 1.5, "有效数字应该正确设置 (Significand should be set correctly)")
    assert_equal(big.exponent, 10, "指数应该正确设置 (Exponent should be set correctly)")
    
    -- 测试通过调用操作符构造 (Test constructor via call operator)
    local via_call = bignum(42)
    assert_bignum_equal(via_call, bignum.new(42), "通过调用操作符构造应该工作 (Construction via call operator should work)")
end

-- 规范化测试 (Normalization tests)
local function test_normalization()
    -- 测试大数的规范化 (Test normalization of large numbers)
    local big = bignum.new(123, 0)
    assert_equal(big.significand, 1.23, "大数应该被规范化 (Large number should be normalized)")
    assert_equal(big.exponent, 2, "指数应该相应调整 (Exponent should be adjusted accordingly)")
    
    -- 测试小数的规范化 (Test normalization of small numbers)
    local small = bignum.new(0.0123, 0)
    assert_equal(small.significand, 1.23, "小数应该被规范化 (Small number should be normalized)")
    assert_equal(small.exponent, -2, "指数应该相应调整 (Exponent should be adjusted accordingly)")
    
    -- 测试零的规范化 (Test normalization of zero)
    local zero = bignum.new(0, 5)
    assert_equal(zero.significand, 0, "零的有效数字应该是0 (Zero's significand should be 0)")
    assert_equal(zero.exponent, 0, "零的指数应该是0 (Zero's exponent should be 0)")
end

-- 字符串转换测试 (String conversion tests)
local function test_tostring()
    -- 测试普通数字 (Test normal numbers)
    local num1 = bignum.new(123)
    assert_equal(tostring(num1), "123", "普通数字应该正确转换为字符串 (Normal number should convert to string correctly)")
    
    -- 测试大数 (Test large numbers)
    local num2 = bignum.new(1.5, 20)
    assert_equal(tostring(num2), "150000000000000000000", "大数应该正确转换为字符串 (Large number should convert to string correctly)")
    
    -- 测试小数 (Test small numbers)
    local num3 = bignum.new(1.5, -2)
    assert_equal(tostring(num3), "0.015", "小数应该正确转换为字符串 (Small number should convert to string correctly)")
    
    -- 测试零 (Test zero)
    local num4 = bignum.new(0)
    assert_equal(tostring(num4), "0", "零应该正确转换为字符串 (Zero should convert to string correctly)")
end

-- 克隆测试 (Clone tests)
local function test_clone()
    local original = bignum.new(3.14, 5)
    local cloned = original:clone()
    
    assert_bignum_equal(cloned, original, "克隆应该创建相等的数字 (Clone should create equal number)")
    
    -- 确保它们是不同的对象 (Ensure they are different objects)
    cloned.significand = 2.71
    assert_equal(original.significand, 3.14, "修改克隆不应该影响原始对象 (Modifying clone should not affect original)")
end

-- 乘法测试 (Multiplication tests)
local function test_multiplication()
    -- 基本乘法 (Basic multiplication)
    local a = bignum.new(2, 3)
    local b = bignum.new(3, 4)
    local result = a * b
    assert_bignum_equal(result, bignum.new(6, 7), "基本乘法应该正确 (Basic multiplication should be correct)")
    
    -- 与零相乘 (Multiplication by zero)
    local zero = bignum.new(0)
    local result_zero = a * zero
    assert_bignum_equal(result_zero, zero, "与零相乘应该得到零 (Multiplication by zero should give zero)")
    
    -- 与一相乘 (Multiplication by one)
    local one = bignum.new(1)
    local result_one = a * one
    assert_bignum_equal(result_one, a, "与一相乘应该得到原数 (Multiplication by one should give original number)")
end

-- 除法测试 (Division tests)
local function test_division()
    -- 基本除法 (Basic division)
    local a = bignum.new(8, 5)
    local b = bignum.new(2, 2)
    local result = a / b
    assert_bignum_equal(result, bignum.new(4, 3), "基本除法应该正确 (Basic division should be correct)")
    
    -- 除以一 (Division by one)
    local one = bignum.new(1)
    local result_one = a / one
    assert_bignum_equal(result_one, a, "除以一应该得到原数 (Division by one should give original number)")
end

-- 比较测试 (Comparison tests)
local function test_comparison()
    local a = bignum.new(1, 5)    -- 1e5
    local b = bignum.new(2, 4)    -- 2e4 = 0.2e5
    local c = bignum.new(1, 5)    -- 1e5 (equal to a)
    
    -- 测试相等 (Test equality)
    assert_equal(a == c, true, "相等的数字应该被识别为相等 (Equal numbers should be recognized as equal)")
    assert_equal(a == b, false, "不相等的数字应该被识别为不相等 (Unequal numbers should be recognized as unequal)")
    
    -- 测试大于 (Test greater than)
    assert_equal(a > b, true, "较大的数字应该被识别为更大 (Larger number should be recognized as greater)")
    assert_equal(b > a, false, "较小的数字不应该被识别为更大 (Smaller number should not be recognized as greater)")
    
    -- 测试小于 (Test less than)
    assert_equal(a < b, false, "较大的数字不应该被识别为更小 (Larger number should not be recognized as smaller)")
    assert_equal(b < a, true, "较小的数字应该被识别为更小 (Smaller number should be recognized as smaller)")
    
    -- 测试负数比较 (Test negative number comparison)
    local neg_a = -a
    local neg_b = -b
    assert_equal(neg_a < neg_b, true, "负数比较应该正确 (Negative number comparison should be correct)")
    assert_equal(neg_a > a, false, "负数应该小于正数 (Negative number should be less than positive)")
end

-- 加法测试 (Addition tests)
local function test_addition()
    -- 基本加法 (Basic addition)
    local a = bignum.new(1, 2)    -- 100
    local b = bignum.new(2, 2)    -- 200
    local result = a + b
    assert_bignum_equal(result, bignum.new(3, 2), "基本加法应该正确 (Basic addition should be correct)")
    
    -- 与零相加 (Addition with zero)
    local zero = bignum.new(0)
    local result_zero = a + zero
    assert_bignum_equal(result_zero, a, "与零相加应该得到原数 (Addition with zero should give original number)")
    
    -- 不同指数的加法 (Addition with different exponents)
    local c = bignum.new(1, 5)    -- 1e5
    local d = bignum.new(1, 2)    -- 1e2
    local result_diff = c + d
    -- 应该是 1e5 + 1e2 = 100000 + 100 = 100100 = 1.001e5
    assert_bignum_equal(result_diff, bignum.new(1.001, 5), "不同指数的加法应该正确 (Addition with different exponents should be correct)")
end

-- 减法测试 (Subtraction tests)
local function test_subtraction()
    -- 基本减法 (Basic subtraction)
    local a = bignum.new(5, 2)    -- 500
    local b = bignum.new(2, 2)    -- 200
    local result = a - b
    assert_bignum_equal(result, bignum.new(3, 2), "基本减法应该正确 (Basic subtraction should be correct)")
    
    -- 减去零 (Subtraction of zero)
    local zero = bignum.new(0)
    local result_zero = a - zero
    assert_bignum_equal(result_zero, a, "减去零应该得到原数 (Subtraction of zero should give original number)")
    
    -- 减去自己 (Subtraction of self)
    local result_self = a - a
    assert_bignum_equal(result_self, zero, "减去自己应该得到零 (Subtraction of self should give zero)")
end

-- 取反测试 (Negation tests)
local function test_negation()
    local a = bignum.new(5, 3)
    local neg_a = -a
    
    assert_equal(neg_a.significand, -5, "取反应该改变符号 (Negation should change sign)")
    assert_equal(neg_a.exponent, 3, "取反不应该改变指数 (Negation should not change exponent)")
    
    -- 双重取反 (Double negation)
    local double_neg = -neg_a
    assert_bignum_equal(double_neg, a, "双重取反应该得到原数 (Double negation should give original number)")
end

-- 绝对值测试 (Absolute value tests)
local function test_absolute_value()
    local positive = bignum.new(5, 3)
    local negative = bignum.new(-5, 3)
    
    assert_bignum_equal(bignum.abs(positive), positive, "正数的绝对值应该是自己 (Absolute value of positive should be itself)")
    assert_bignum_equal(bignum.abs(negative), positive, "负数的绝对值应该是对应的正数 (Absolute value of negative should be corresponding positive)")
end

-- 倒数测试 (Inverse tests)
local function test_inverse()
    local a = bignum.new(4, 3)
    local inv_a = bignum.inverse(a)
    local result = a * inv_a
    
    assert_bignum_equal(result, bignum.new(1), "数字乘以其倒数应该等于一 (Number times its inverse should equal one)")
end

-- 幂运算测试 (Power tests)
local function test_power()
    -- 基本幂运算 (Basic power)
    local base = bignum.new(2)
    local result = base ^ 3
    assert_bignum_equal(result, bignum.new(8), "基本幂运算应该正确 (Basic power should be correct)")
    
    -- 零次幂 (Power of zero)
    local result_zero_exp = base ^ 0
    assert_bignum_equal(result_zero_exp, bignum.new(1), "任何数的零次幂应该等于一 (Any number to power of zero should equal one)")
    
    -- 一次幂 (Power of one)
    local result_one_exp = base ^ 1
    assert_bignum_equal(result_one_exp, base, "任何数的一次幂应该等于自己 (Any number to power of one should equal itself)")
    
    -- 负数幂 (Negative power)
    local result_neg_exp = base ^ (-2)
    assert_bignum_equal(result_neg_exp, bignum.new(0.25), "负数幂应该等于倒数的正数幂 (Negative power should equal reciprocal of positive power)")
end

-- 边界情况测试 (Edge case tests)
local function test_edge_cases()
    -- 测试零 (Test zero)
    local zero = bignum.new(0)
    assert_bignum_equal(zero + zero, zero, "零加零应该等于零 (Zero plus zero should equal zero)")
    assert_bignum_equal(zero * bignum.new(100), zero, "零乘以任何数应该等于零 (Zero times any number should equal zero)")
    
    -- 测试非常大的数 (Test very large numbers)
    local very_large = bignum.new(9.99, 100)
    local result_large = very_large + bignum.new(1, 95)  -- 添加一个相对较小的数
    -- 由于大数的精度限制，小数应该被忽略
    assert_bignum_equal(result_large, very_large, "非常大的数加上小数应该忽略小数 (Very large number plus small number should ignore small number)")
    
    -- 测试除零错误处理 (Test division by zero error handling)
    local success, _ = pcall(function() return bignum.new(5) / zero end)
    assert_equal(success, false, "除零应该产生错误 (Division by zero should produce error)")
    
    -- 测试0^0的处理 (Test 0^0 handling)
    assert_bignum_equal(zero ^ 0, bignum.new(1), "0的0次幂应该等于1 (0 to power 0 should equal 1)")
    
    -- 测试0的负数次幂错误处理 (Test 0 to negative power error handling)
    local success2, _ = pcall(function() return zero ^ (-1) end)
    assert_equal(success2, false, "0的负数次幂应该产生错误 (0 to negative power should produce error)")
end

-- 主测试函数 (Main test function)
local function run_all_tests()
    print("开始运行大数库测试 (Starting bignum library tests)")
    print("=" .. string.rep("=", 50))
    
    -- 运行所有测试 (Run all tests)
    run_test("构造函数测试 (Constructor tests)", test_constructor)
    run_test("规范化测试 (Normalization tests)", test_normalization)
    run_test("字符串转换测试 (String conversion tests)", test_tostring)
    run_test("克隆测试 (Clone tests)", test_clone)
    run_test("乘法测试 (Multiplication tests)", test_multiplication)
    run_test("除法测试 (Division tests)", test_division)
    run_test("比较测试 (Comparison tests)", test_comparison)
    run_test("加法测试 (Addition tests)", test_addition)
    run_test("减法测试 (Subtraction tests)", test_subtraction)
    run_test("取反测试 (Negation tests)", test_negation)
    run_test("绝对值测试 (Absolute value tests)", test_absolute_value)
    run_test("倒数测试 (Inverse tests)", test_inverse)
    run_test("幂运算测试 (Power tests)", test_power)
    run_test("边界情况测试 (Edge case tests)", test_edge_cases)
    
    print("=" .. string.rep("=", 50))
    print("所有测试完成 (All tests completed)")
end

-- 如果直接运行此文件，则执行测试 (If running this file directly, execute tests)
if arg and arg[0] and arg[0]:match("test_bignum.lua$") then
    run_all_tests()
end

-- 返回测试函数以便外部调用 (Return test function for external use)
return {
    run_all_tests = run_all_tests,
    run_test = run_test
}