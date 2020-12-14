def reverse_num(num):
    rev_num = ''
    for i in str(num):
        rev_num = i + rev_num
    return int(rev_num)

def prime_finder():
    yield 2
    set_of_primes = [2]
    num = 3
    while True:
        prime=0
        for i in set_of_primes:
            if num%i == 0:
                prime=1
                break
        if prime==0:
            yield num
            set_of_primes.append(num)
        num+=2

def backwardsPrime(num1,num2):
    if num1>num2:
        print('Error! Second number must be larger than first number.')
        return
    list_of_all_primes = []
    reg_primes_in_range = []
    backwards_primes = []
    prime_generator1 = prime_finder()
    for i in prime_generator1:
        if i>num2:
            break
        if num1<=i:
            reg_primes_in_range.append(i)
        list_of_all_primes.append(i)
    prime_and_rev_dict = {}
    for j in reg_primes_in_range:
        if j != reverse_num(j):
            prime_and_rev_dict[j] = reverse_num(j)
    if len(prime_and_rev_dict)!=0:
        for k in prime_generator1:
            if k > max(prime_and_rev_dict.values()):
                break
            else:
                list_of_all_primes.append(k)
        for m in prime_and_rev_dict:
            if prime_and_rev_dict[m] in list_of_all_primes:
                backwards_primes.append(m)
    return backwards_primes