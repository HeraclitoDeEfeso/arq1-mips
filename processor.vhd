library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity processor is
port(
	Clk         : in  std_logic;
	Reset       : in  std_logic;
	-- Instruction memory
	I_Addr      : out std_logic_vector(31 downto 0);
	I_RdStb     : out std_logic;
	I_WrStb     : out std_logic;
	I_DataOut   : out std_logic_vector(31 downto 0);
	I_DataIn    : in  std_logic_vector(31 downto 0);
	-- Data memory
	D_Addr      : out std_logic_vector(31 downto 0);
	D_RdStb     : out std_logic;
	D_WrStb     : out std_logic;
	D_DataOut   : out std_logic_vector(31 downto 0);
	D_DataIn    : in  std_logic_vector(31 downto 0)
);
end processor;

architecture processor_arq of processor is 

component ALU 
    port  (a : in STD_LOGIC_VECTOR (31 downto 0);
           b : in STD_LOGIC_VECTOR (31 downto 0);
           control : in STD_LOGIC_VECTOR (2 downto 0);
           zero : out STD_LOGIC;
           result : out STD_LOGIC_VECTOR (31 downto 0));
           
end component;

component unidad_forwarding 
    Port ( 		--Entradas
				id_ex_rs : in  STD_LOGIC_VECTOR(4 downto 0);--MUX A "00"
				id_ex_rt : in  STD_LOGIC_VECTOR(4 downto 0);--MUX B "00"
				ex_mem_regWrite : in  STD_LOGIC;
				ex_mem_rd : in  STD_LOGIC_VECTOR(4 downto 0);--MUX A/B "10"
				mem_wb_regWrite : in  STD_LOGIC;
				mem_wb_rd : in  STD_LOGIC_VECTOR(4 downto 0);--MUX A/B "01"
				--Salidas
				anticipar_a : out STD_LOGIC_VECTOR(1 downto 0);--Selector MUX A 
				anticipar_b : out STD_LOGIC_VECTOR(1 downto 0));--Selector MUX B 
end component;			  
			  

component registers 
    port  (clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           wr : in STD_LOGIC;
           reg1_dr : in STD_LOGIC_VECTOR (4 downto 0);
           reg2_dr : in STD_LOGIC_VECTOR (4 downto 0);
           reg_wr : in STD_LOGIC_VECTOR (4 downto 0);
           data_wr : in STD_LOGIC_VECTOR (31 downto 0);
           data1_rd : out STD_LOGIC_VECTOR (31 downto 0);
           data2_rd : out STD_LOGIC_VECTOR (31 downto 0));
           
end component;

--DECLARACION DE SE�ALES--
      --ETAPA IF--
signal PC: std_logic_vector (31 downto 0);
signal PC_4: std_logic_vector (31 downto 0);
signal PCSRC: std_logic;
signal next_PC: std_logic_vector (31 downto 0);
signal MUX_PCSRC: std_logic_vector (31 downto 0);

      --ETAPA ID--
signal ID_data1_rd: std_logic_vector (31 downto 0);
signal ID_data2_rd: std_logic_vector (31 downto 0);
signal ID_RegWrite: std_logic;
signal ID_MemToReg: std_logic;
signal ID_MemRead: std_logic;
signal ID_MemWrite: std_logic;
signal ID_Branch: std_logic;
signal ID_RegDst: std_logic;
signal ID_AluOp: std_logic_vector(2 downto 0);
signal ID_ALUSrc: std_logic;
signal ID_immediate: std_logic_vector (31 downto 0);
signal ID_rt: std_logic_vector (4 downto 0);
signal ID_rd: std_logic_vector (4 downto 0);
signal ID_rs: std_logic_vector (4 downto 0);
signal ID_PC_4: std_logic_vector (31 downto 0);
signal ID_Instruction: std_logic_vector (31 downto 0);
signal ID_JUMP_ADDR: std_logic_vector (25 downto 0);
signal ID_JUMP: std_logic;

      --ETAPA EX--
signal EX_RegWrite: std_logic;
signal EX_MemToReg: std_logic;
signal EX_MemRead: std_logic;
signal EX_MemWrite: std_logic;
signal EX_Branch: std_logic;
signal RegDst: std_logic;
signal ALUOp: std_logic_vector(2 downto 0);
signal ALUSrc: std_logic;
signal EX_data1_rd: std_logic_vector (31 downto 0);
signal EX_data2_rd: std_logic_vector (31 downto 0);
signal ALUResult: std_logic_vector (31 downto 0);
signal zero: std_logic;
signal EX_immediate: std_logic_vector (31 downto 0);
signal EX_rs: std_logic_vector (4 downto 0);
signal EX_rt: std_logic_vector (4 downto 0);
signal EX_rd: std_logic_vector (4 downto 0);
signal ALU_B_In: std_logic_vector (31 downto 0);
signal EX_Instruction_RegDst: std_logic_vector (4 downto 0);
signal EX_PC_4: std_logic_vector (31 downto 0);
signal EX_PC_Branch: std_logic_vector (31 downto 0);
signal ALUControl: std_logic_vector (2 downto 0);
signal selector_A: std_logic_vector(1 downto 0);
signal selector_B: std_logic_vector(1 downto 0);
signal MUXA_out: std_logic_vector (31 downto 0);
signal MUXB_out: std_logic_vector (31 downto 0);
signal EX_JUMP_ADDR: std_logic_vector (27 downto 0);
signal EX_JUMP: std_logic;
signal JUMP_VALUE: std_logic_vector (31 downto 0);

      
      --ETAPA MEM--
signal MEM_PC_Branch: std_logic_vector (31 downto 0);
signal MEM_RegWrite: std_logic;
signal MEM_MemToReg: std_logic;
signal MEM_AluResult: std_logic_vector (31 downto 0);
signal Branch: std_logic;
signal MEM_Zero: std_logic;
signal MEM_Instruction_RegDst: std_logic_vector (4 downto 0);
signal MEM_MemRead: std_logic;
signal MEM_MemWrite: std_logic;
signal MEM_data2_rd: std_logic_vector (31 downto 0);
signal MEM_rd: std_logic_vector (4 downto 0);
     
      --ETAPA WB--
signal WB_reg_wr: std_logic_vector (4 downto 0);
signal WB_data_wr: std_logic_vector (31 downto 0);
signal MemToReg: std_logic;
signal RegWrite: std_logic;
signal WB_AluResult: std_logic_vector (31 downto 0);
signal WB_MemData: std_logic_vector (31 downto 0);
signal WB_rd: std_logic_vector (4 downto 0);
       
        
begin 	
---------------------------------------------------------------------------------------------------------------
-- ETAPA IF
---------------------------------------------------------------------------------------------------------------
 -- Contador de programa
 PCCount: process(clk, reset)
  begin
    if reset = '1' then
      PC <= ( others =>'0');
    elsif rising_edge(clk) then
      PC <= next_PC;
    end if;
  end process;

  PC_4 <= PC + 4;
  MUX_PCSRC <= PC_4 when (PcSrc = '0') else MEM_PC_Branch;
  next_PC <= MUX_PCSRC when (EX_JUMP = '0') else JUMP_VALUE;
	
-- Interfaz con memoria de Instrucciones
  I_Addr <= PC;
  I_RdStb <= '1';
  I_WrStb <= '0';
  I_DataOut <= (others => '0');
 
---------------------------------------------------------------------------------------------------------------
-- REGISTRO DE SEGMENTACION IF/ID
--------------------------------------------------------------------------------------------------------------- 
 IF_ID : process(clk,reset)
  begin
    if reset ='1' then
      ID_PC_4 <= (others => '0');
      ID_Instruction <= (others => '0');
    elsif rising_edge(clk) then
      ID_PC_4 <= PC_4;
      ID_Instruction <= I_DataIn;
    end if;
  end process;
 
 
---------------------------------------------------------------------------------------------------------------
-- ETAPA ID
---------------------------------------------------------------------------------------------------------------
-- Instanciacion del banco de registros
Registers_inst:  registers 
	Port map (
			clk => clk, 
			reset => reset, 
			wr => RegWrite, 
			reg1_dr => ID_Instruction(25 downto 21), 
			reg2_dr => ID_Instruction( 20 downto 16), 
			reg_wr => WB_reg_wr, 
			data_wr => WB_data_wr , 
			data1_rd => ID_data1_rd ,
			data2_rd => ID_data2_rd ); 

-- UNIDAD DE CONTROL
 CONTROL_UNIT: process (ID_Instruction) 
   begin
      case ID_Instruction(31 downto 26) is
      --R-Type--
      when "000000" => 
				ID_RegWrite<= '1'; 
				ID_MemToReg<= '0'; 
				ID_MemRead<= '0'; 
				ID_MemWrite<= '0'; 
				ID_Branch<= '0'; 
				ID_RegDst<= '1'; 
				ID_AluOp<= "010"; 
				ID_ALUSrc<= '0';
				ID_JUMP<= '0';
      --LW--
      when "100011" => 
				ID_RegWrite<= '1'; 
				ID_MemToReg<= '1'; 
				ID_MemRead<= '1'; 
				ID_MemWrite<= '0'; 
				ID_Branch<= '0'; 
				ID_RegDst<= '0'; 
				ID_AluOp<= "000"; 
				ID_ALUSrc<= '1';
				ID_JUMP<= '0';
      --SW--
      when "101011" => 
				ID_RegWrite<= '0'; 
				ID_MemToReg<= '0'; 
				ID_MemRead<= '0'; 
				ID_MemWrite<= '1'; 
				ID_Branch<= '0'; 
				ID_RegDst<= '0'; 
				ID_AluOp<= "000"; 
				ID_ALUSrc<= '1';
				ID_JUMP<= '0';
      --BEQ--
      when "000100" => 
				ID_RegWrite<= '0'; 
				ID_MemToReg<= '0'; 
				ID_MemRead<= '0'; 
				ID_MemWrite<= '0'; 
				ID_Branch<= '1'; 
				ID_RegDst<= '0'; 
				ID_AluOp<= "001"; 
				ID_ALUSrc<= '0';
				ID_JUMP<= '0';
      --ADDI--
      when "001000" => 
				ID_RegWrite<= '1'; 
				ID_MemToReg<= '0'; 
				ID_MemRead<= '0'; 
				ID_MemWrite<= '0'; 
				ID_Branch<= '0'; 
				ID_RegDst<= '0'; 
				ID_AluOp<= "000"; 
				ID_ALUSrc<= '1';
				ID_JUMP<= '0';
      --ANDI--
      when "001100" => 
				ID_RegWrite<= '1'; 
				ID_MemToReg<= '0'; 
				ID_MemRead<= '0'; 
				ID_MemWrite<= '0'; 
				ID_Branch<= '0'; 
				ID_RegDst<= '0'; 
				ID_AluOp<= "100"; 
				ID_ALUSrc<= '1';
				ID_JUMP<= '0';
      --ORI--
      when "001101" => 
				ID_RegWrite<= '1'; 
				ID_MemToReg<= '0'; 
				ID_MemRead<= '0'; 
				ID_MemWrite<= '0'; 
				ID_Branch<= '0'; 
				ID_RegDst<= '0'; 
				ID_AluOp<= "101"; 
				ID_ALUSrc<= '1';
				ID_JUMP<= '0';
	--LUI--
	when "001111" => 
				ID_RegWrite<= '1'; 
				ID_MemToReg<= '0'; 
				ID_MemRead<= '0'; 
				ID_MemWrite<= '0'; 
				ID_Branch<= '0'; 
				ID_RegDst<= '0'; --Reg RT--
				ID_AluOp<= "011"; --Desplaza Inmediate a parte alta--
				ID_ALUSrc<= '1';  --Selecciona Inmediato como operando
				ID_JUMP<= '0';
	--J Salto Incondicional--
	when "000010" =>
				ID_RegWrite<= '0'; 
				ID_MemToReg<= '0'; 
				ID_MemRead<= '0'; 
				ID_MemWrite<= '0'; 
				ID_Branch<= '0'; 
				ID_RegDst<= '0'; 
				ID_AluOp<= "000"; 
				ID_ALUSrc<= '0';  
				ID_JUMP<= '1';
      when others => 
				ID_RegWrite<= '0'; 
				ID_MemToReg<= '0'; 
				ID_MemRead<= '0'; 
				ID_MemWrite<= '0'; 
				ID_Branch<= '0'; 
				ID_RegDst<= '0'; 
				ID_AluOp<= "000"; 
				ID_ALUSrc<= '0';
				ID_JUMP<= '0';
    end case;
  end process;
  
  ID_immediate <= (x"FFFF"&ID_Instruction(15 downto 0)) when ID_Instruction(15) = '1' else (x"0000"&ID_Instruction(15 downto 0));
  Id_rs <= ID_instruction(25 downto 21);
  ID_rt <= ID_Instruction(20 downto 16);
  ID_rd <= ID_Instruction(15 downto 11);
  ID_JUMP_ADDR <= ID_Instruction(25 downto 0);

---------------------------------------------------------------------------------------------------------------
-- REGISTRO DE SEGMENTACION ID/EX
---------------------------------------------------------------------------------------------------------------
ID_EX: process(clk, reset)
  begin 
    if (reset = '1' ) then
      EX_data1_rd <= (others =>'0');
      EX_data2_rd <= (others =>'0');
      EX_RegWrite <= '0' ;
      EX_MemToReg <= '0' ; 
      EX_MemRead <=  '0' ;
      EX_MemWrite <=  '0' ;
      EX_Branch <=  '0' ;
      RegDst <=  '0' ;
      ALUOp <= (others =>'0');
      ALUSrc <= '0' ;
      EX_immediate <= (others => '0');
      EX_rs <= (others => '0');
      EX_rt <= (others => '0');
      EX_rd <= (others => '0');
      EX_JUMP_ADDR <= (others => '0');
      EX_JUMP <= '0' ;
    elsif( rising_edge (clk)) then
      EX_data1_rd <= ID_data1_rd;
      EX_data2_rd <= ID_data2_rd;
      EX_RegWrite <= ID_RegWrite;
      EX_MemToReg <= ID_MemToReg;
      EX_MemRead <= ID_MemRead;
      EX_MemWrite <= ID_MemWrite;
      EX_Branch <= ID_Branch;
      RegDst <= ID_RegDst;
      ALUOp <= ID_AluOp;
      ALUSrc <= ID_ALUSrc;
      EX_immediate <= ID_immediate;
      EX_rs <= ID_rs;
      EX_rt <= ID_rt;
      EX_rd <= ID_rd;
      EX_PC_4 <= ID_PC_4;
      EX_JUMP_ADDR <= ID_JUMP_ADDR&"00"; --Guardo directamente en el registro de segmentacion el salto desplazado--
      EX_JUMP <= ID_JUMP;

    end if;
end process;
 
---------------------------------------------------------------------------------------------------------------
-- ETAPA EX
---------------------------------------------------------------------------------------------------------------
-- Instanciacion de ALU
ALU_inst: alu 
	port map(
		a => MUXA_out, 
		b => ALU_B_In, 
      control => AluControl,
      zero => zero, 
		result => ALUResult);
		
-- Instanciacion de Unidad de Forwarding
unidad_forwarding_inst: unidad_forwarding
				
	port map(
		id_ex_rs => EX_rs,
		id_ex_rt =>EX_rt,
		ex_mem_regWrite => MEM_regWrite,
		ex_mem_rd =>MEM_rd,
		mem_wb_regWrite => RegWrite,
		mem_wb_rd => WB_rd,
		anticipar_a => selector_A,
		anticipar_b => selector_B);
		
-- Unidad de Control de ALU
controlAlu : process( EX_immediate, AluOp)
begin 
   case (AluOp) is 
      when "000" =>
         AluControl <= "010"; -- Load and Store
      when "001" =>
         AluControl <= "110"; -- BEQ
      when "010" => -- R Type
         if EX_immediate(5 downto 0) = "100000" then
            AluControl <= "010"; -- ADD
         elsif EX_immediate(5 downto 0) = "100010" then
            AluControl <= "110"; --SUB
         elsif EX_immediate(5 downto 0) = "100100" then
            AluControl <= "000"; --AND
         elsif EX_immediate(5 downto 0) = "100101" then
            AluControl <= "001"; --OR
         elsif EX_immediate(5 downto 0) = "101010" then
            AluControl <= "111"; --SLT
         else 
            AluControl <= "000";
         end if;
      when "100" =>
         AluControl <= "000"; -- ANDI
      when "101" =>
         AluControl <= "001"; -- ORI
      when "011" =>
         AluControl <= "100"; --LUI
      when others => 
         AluControl <= "000";
   end case;
end process;

-- MUX B
MUXB : process( selector_b, EX_data2_rd,WB_data_wr,MEM_AluResult)
begin 
	case selector_b is
		when "01" => 
			MUXB_out <= WB_data_wr;
		when "10" => 
			MUXB_out <= MEM_AluResult;
		when Others => 
			MUXB_out <= EX_data2_rd;
		end case;
end process;

-- MUX A
MUXA : process( selector_a, EX_data1_rd,WB_data_wr,MEM_AluResult)
begin 
	case selector_a is
		when "01" => 
			MUXA_out <= WB_data_wr;
		when "10" => 
			MUXA_out <= MEM_AluResult;
		when Others => 
			MUXA_out <= EX_data1_rd;
		end case;
end process;

-- MUX ALUSrc
ALU_B_In <= MUXB_out when ALUSrc = '0' else EX_immediate; 

-- MUX RegDst
EX_Instruction_RegDst <= EX_rt when RegDst  = '0' else EX_rd; 
  
-- Calculo de direcci�n de salto
EX_PC_Branch <= (EX_PC_4)+(EX_immediate(29 downto 0)&"00");

--Formacion direccion de salto concatencando PC & JUMP_ADDR
JUMP_VALUE <=EX_PC_4(31 downto 28)&EX_JUMP_ADDR;

---------------------------------------------------------------------------------------------------------------
-- REGISTRO DE SEGMENTACION EX/MEM
---------------------------------------------------------------------------------------------------------------
EX_MEM: process(clk, reset)
  begin 
    if (reset = '1' ) then
      MEM_RegWrite <= '0';
      MEM_MemToReg <= '0';
      Branch <= '0';
      MEM_MemRead <= '0';
      MEM_MemWrite <= '0';
      MEM_Zero <= '0';
      MEM_AluResult <= (others => '0');
      MEM_data2_rd <= (others => '0');
      MEM_Instruction_RegDst <= (others => '0');
		MEM_PC_Branch <= (others => '0');
	elsif( rising_edge (clk)) then
      MEM_RegWrite <= EX_RegWrite;
      MEM_MemToReg <= EX_MemToReg;
      Branch <= EX_Branch;
      MEM_MemRead <= EX_MemRead;
      MEM_MemWrite <= EX_MemWrite;
      MEM_Zero <= Zero;
      MEM_AluResult <= ALUResult;
      MEM_data2_rd <= EX_data2_rd;
      MEM_Instruction_RegDst <= EX_Instruction_RegDst;
      MEM_rd <= EX_rd;
		MEM_PC_Branch <= EX_PC_Branch; 
    end if;
end process;


---------------------------------------------------------------------------------------------------------------
-- ETAPA MEM
---------------------------------------------------------------------------------------------------------------
PCSrc <= (Branch and MEM_Zero);
D_Addr <= MEM_AluResult;
D_RdStb <= MEM_MemRead;
D_WrStb <= MEM_MemWrite;
D_DataOut <= MEM_data2_rd;


---------------------------------------------------------------------------------------------------------------
-- REGISTRO DE SEGMENTACION MEM/WB
---------------------------------------------------------------------------------------------------------------
EX_MEM_ETAPA: process(clk, reset)
  begin 
    if (reset = '1' ) then
		 RegWrite <= '0';
		 MemToReg <= '0' ; 
		 WB_MemData <= (others => '0');
		 WB_AluResult <= (others => '0');
		 WB_reg_wr <= (others => '0');
	elsif( rising_edge (clk)) then
		 RegWrite <= MEM_RegWrite;
		 MemToReg <= MEM_MemToReg;  
		 WB_MemData <= D_DataIn;
		 WB_AluResult <= MEM_AluResult; 
		 WB_reg_wr <= MEM_Instruction_RegDst;
		 WB_rd <= MEM_rd;
    end if;
end process;

---------------------------------------------------------------------------------------------------------------
-- ETAPA WB
---------------------------------------------------------------------------------------------------------------
WB_data_wr <= WB_AluResult when MemToReg = '0' else 
					WB_MemData ; 


end processor_arq;