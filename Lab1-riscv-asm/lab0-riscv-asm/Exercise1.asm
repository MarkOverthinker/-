	lui   s1,0xFFFFF
	
switled:                          # Test led and switch
	addi a0, zero, 0	  #重置答案a0
	addi t2, zero, 0            #重置判断数t2
	lw   s0,0x70(s1)          # read switch
	andi a1, s0, 0xFF       #得到操作数A存入a1
	srli a2, s0, 0x8        #将操作数B移到低位存入a2
	srli t0, s0, 0x15       #将运算类型码移到低位存入t0
	srli a3, s0, 0x7	#将A的符号位移到低位存入a3
	srli a4, s0, 0xF	#将B的符号位移到低位存入a4
	andi a2, a2, 0xFF       #得到操作数B存入a2
	andi t0, t0, 0xF        #得到运算类型码存入t0
	andi a3, a3, 0x1	#得到A的符号位存入a3
	andi a4, a4, 0x1	#得到B的符号位存入a4	
	jal judge		#进行相应运算

judge:
	beq t0, t2, tonof
	addi t2, t2, 1		#判断是否为001
	beq t0, t2, toadd 
	addi t2, t2, 1		#判断是否为010
	beq t0, t2, tosub
	addi t2, t2, 1		#判断是否为011
	beq t0, t2, toand
	addi t2, t2, 1		#判断是否为100
	beq t0, t2, toor
	addi t2, t2, 1		#判断是否为101
	beq t0, t2, tosll
	addi t2, t2, 1          #判断是否为110
	beq t0, t2, tosra
	addi t2, t2, 1		#判断是否是111
	beq t0, t2, tomult
	
tonof:
	sw   s0,0x60(s1)          # write led	
    	sw   s0,0x00(s1)
	jal switled
	
ledhelper:
	sw a0, 0x60(s1)     # 输出答案到led
	sw a0, 0x00(s1)
	jal switled     # 循环跳转
	
toadd:
	beq a3, zero, j1	# 若A为正，跳转到B的判断，否则求其补码
	jal tp, atocom		# 若A为负，用atocom函数求补码，并将下一条指令地址保存在tp中
j1:	beq a4, zero, j2	# 若B为正，直接跳转到运算，否则求其补码
	jal tp, btocom		# 若B为负，用btocom函数求补码，并将下一条指令地址保存在tp中
j2:	add a0, a1, a2       # A + B
	andi a0, a0, 0xFF	#取低八位有效位
	srli a5, a0, 0x7	#取答案符号位
	beq a5, zero, ledhelper	# 答案为正直接输出
	jal ratocom		# 答案为负则再求一次补码得原码输出
	
ratocom:
	xori a0, a0, 0x7F	#数值位取反
	addi a0, a0, 11		#加一得补码
	jal ledhelper		#输出答案
	
tosub:
	xori a2, a2, 0x80	# B 变为 -B，再执行A + (-B)
	xori a4, a4, 0x1	# B 的符号位也要反转
	jal toadd     # 转为加法运算
	
toand:
	and a0, a1, a2        # A & B
	jal ledhelper       #输出答案并跳转
	
toor:
	or a0, a1, a2         # A | B
	jal ledhelper         #输出答案并跳转
	
tosll:
	sll a0, a1, a2       # A << B
	jal ledhelper	    # 输出答案并跳转
	
tosra:
	sra a0, a1, a2	    # A >> B (算术右移)
	beq a3, zero, ledhelper  # A 为正则无需额外操作，否则需要补1
	jal srahelper   # 跳到srahelper进行补位，并输出答案	
	
srahelper:
	slli s7, a3, 0x8     # 符号位左移8位存入s7
	addi s9, zero, 0x8   # 将8存入s9
	sub s9, s9, a2		# 将8与B的差值存入s9	
	sll s8, a3, s9		# 将符号位左移s9位
	sub s10, s7, s8		# 用s7 - s8得到符号位掩码
	or a0, a0, s10		#将答案与掩码作或运算得到最终答案
	jal ledhelper		#输出答案并跳转
	
tomult:
	andi a1, a1, 0x7F	#符号位归0
	andi a2, a2, 0x7F	#符号位归0
	jal multhelper
	
multhelper:
	beq a2, zero, multend	# B为0，运算结束
	andi s5, a2, 0x1	# 获取B最低位
	beq s5, zero, j3	# B最低为为0则不加， 不为0则加
	add a0, a0, a1		# a0加上A
j3:	slli a1, a1, 0x1	# A左移一位
	srli a2, a2, 0x1	# B右移一位
	jal multhelper		# 继续运算
	
multend:
	xor s4, a3, a4		# 运算结束，获取符号位
	slli s4, s4, 0xE		# 得到答案符号位
	or a0, a0, s4		# 符号位赋给答案
	jal ledhelper		# 输出答案并跳转
	
atocom:          # 求A的补码
	xori a1, a1, 0x7F       # A数值位取反
	addi a1, a1, 1		# 加一形成补码
	jalr zero, 0(tp)
	
btocom:		# 求B的补码	
	xori a2, a2, 0x7F	# B数值位取反
	addi a2, a2, 1		# B加一形成补码
	jalr zero, 0(tp)	
	
	
	
