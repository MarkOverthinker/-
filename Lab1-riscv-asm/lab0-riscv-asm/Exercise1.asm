	lui   s1,0xFFFFF
	
switled:                          # Test led and switch
	addi a0, zero, 0	  #���ô�a0
	addi t2, zero, 0            #�����ж���t2
	lw   s0,0x70(s1)          # read switch
	andi a1, s0, 0xFF       #�õ�������A����a1
	srli a2, s0, 0x8        #��������B�Ƶ���λ����a2
	srli t0, s0, 0x15       #�������������Ƶ���λ����t0
	srli a3, s0, 0x7	#��A�ķ���λ�Ƶ���λ����a3
	srli a4, s0, 0xF	#��B�ķ���λ�Ƶ���λ����a4
	andi a2, a2, 0xFF       #�õ�������B����a2
	andi t0, t0, 0xF        #�õ��������������t0
	andi a3, a3, 0x1	#�õ�A�ķ���λ����a3
	andi a4, a4, 0x1	#�õ�B�ķ���λ����a4	
	jal judge		#������Ӧ����

judge:
	beq t0, t2, tonof
	addi t2, t2, 1		#�ж��Ƿ�Ϊ001
	beq t0, t2, toadd 
	addi t2, t2, 1		#�ж��Ƿ�Ϊ010
	beq t0, t2, tosub
	addi t2, t2, 1		#�ж��Ƿ�Ϊ011
	beq t0, t2, toand
	addi t2, t2, 1		#�ж��Ƿ�Ϊ100
	beq t0, t2, toor
	addi t2, t2, 1		#�ж��Ƿ�Ϊ101
	beq t0, t2, tosll
	addi t2, t2, 1          #�ж��Ƿ�Ϊ110
	beq t0, t2, tosra
	addi t2, t2, 1		#�ж��Ƿ���111
	beq t0, t2, tomult
	
tonof:
	sw   s0,0x60(s1)          # write led	
    	sw   s0,0x00(s1)
	jal switled
	
ledhelper:
	sw a0, 0x60(s1)     # ����𰸵�led
	sw a0, 0x00(s1)
	jal switled     # ѭ����ת
	
toadd:
	beq a3, zero, j1	# ��AΪ������ת��B���жϣ��������䲹��
	jal tp, atocom		# ��AΪ������atocom�������룬������һ��ָ���ַ������tp��
j1:	beq a4, zero, j2	# ��BΪ����ֱ����ת�����㣬�������䲹��
	jal tp, btocom		# ��BΪ������btocom�������룬������һ��ָ���ַ������tp��
j2:	add a0, a1, a2       # A + B
	andi a0, a0, 0xFF	#ȡ�Ͱ�λ��Чλ
	srli a5, a0, 0x7	#ȡ�𰸷���λ
	beq a5, zero, ledhelper	# ��Ϊ��ֱ�����
	jal ratocom		# ��Ϊ��������һ�β����ԭ�����
	
ratocom:
	xori a0, a0, 0x7F	#��ֵλȡ��
	addi a0, a0, 11		#��һ�ò���
	jal ledhelper		#�����
	
tosub:
	xori a2, a2, 0x80	# B ��Ϊ -B����ִ��A + (-B)
	xori a4, a4, 0x1	# B �ķ���λҲҪ��ת
	jal toadd     # תΪ�ӷ�����
	
toand:
	and a0, a1, a2        # A & B
	jal ledhelper       #����𰸲���ת
	
toor:
	or a0, a1, a2         # A | B
	jal ledhelper         #����𰸲���ת
	
tosll:
	sll a0, a1, a2       # A << B
	jal ledhelper	    # ����𰸲���ת
	
tosra:
	sra a0, a1, a2	    # A >> B (��������)
	beq a3, zero, ledhelper  # A Ϊ����������������������Ҫ��1
	jal srahelper   # ����srahelper���в�λ���������	
	
srahelper:
	slli s7, a3, 0x8     # ����λ����8λ����s7
	addi s9, zero, 0x8   # ��8����s9
	sub s9, s9, a2		# ��8��B�Ĳ�ֵ����s9	
	sll s8, a3, s9		# ������λ����s9λ
	sub s10, s7, s8		# ��s7 - s8�õ�����λ����
	or a0, a0, s10		#������������������õ����մ�
	jal ledhelper		#����𰸲���ת
	
tomult:
	andi a1, a1, 0x7F	#����λ��0
	andi a2, a2, 0x7F	#����λ��0
	jal multhelper
	
multhelper:
	beq a2, zero, multend	# BΪ0���������
	andi s5, a2, 0x1	# ��ȡB���λ
	beq s5, zero, j3	# B���ΪΪ0�򲻼ӣ� ��Ϊ0���
	add a0, a0, a1		# a0����A
j3:	slli a1, a1, 0x1	# A����һλ
	srli a2, a2, 0x1	# B����һλ
	jal multhelper		# ��������
	
multend:
	xor s4, a3, a4		# �����������ȡ����λ
	slli s4, s4, 0xE		# �õ��𰸷���λ
	or a0, a0, s4		# ����λ������
	jal ledhelper		# ����𰸲���ת
	
atocom:          # ��A�Ĳ���
	xori a1, a1, 0x7F       # A��ֵλȡ��
	addi a1, a1, 1		# ��һ�γɲ���
	jalr zero, 0(tp)
	
btocom:		# ��B�Ĳ���	
	xori a2, a2, 0x7F	# B��ֵλȡ��
	addi a2, a2, 1		# B��һ�γɲ���
	jalr zero, 0(tp)	
	
	
	
