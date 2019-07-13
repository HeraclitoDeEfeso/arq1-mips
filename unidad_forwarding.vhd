-- unidad_forwarding.vhd created on 3:30  2019.7.13

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity unidad_forwarding is
    Port ( 			
    			--Entradas
				id_ex_rs : in  STD_LOGIC_VECTOR(4 downto 0);--MUX A "00"
				id_ex_rt : in  STD_LOGIC_VECTOR(4 downto 0);--MUX B "00"
				
				ex_mem_regWrite : in  STD_LOGIC;
				ex_mem_rd : in  STD_LOGIC_VECTOR(4 downto 0);--MUX A/B "10"
				
				mem_wb_regWrite : in  STD_LOGIC;
				mem_wb_rd : in  STD_LOGIC_VECTOR(4 downto 0);--MUX A/B "01"
				
				--Salidas
				anticipar_a : out STD_LOGIC_VECTOR(1 downto 0);--Selector MUX A 
				anticipar_b : out STD_LOGIC_VECTOR(1 downto 0);--Selector MUX B 
			  );
end unidad_forwarding;

architecture Behavioral of unidad_forwarding is

begin

	process(ex_mem_regWrite, ex_mem_rd, mem_wb_regWrite, 
			  mem_wb_rd, id_ex_rs, id_ex_rt ) is
	begin

	-- Anticipar A(Modificara la salida del Mux A que le da el primer dato a la alu)
		-- La instruccion que esta en la estapa EX/MEM modificara el RS que usara la alu (Riesgo en EX Nro 1)
		if ((ex_mem_regWrite = '1')
			and (ex_mem_rd /="00000") 
			and (ex_mem_rd = id_ex_rs)) 
			then anticipar_a <= b"10"; 
			
		-- La instruccion que esta en la estapa MEM/WB modificara el RS que usara la alu (Riesgo en MEM Nro 1)	
		elsif ((mem_wb_regWrite = '1')
			and (mem_wb_rd /="00000") 
			-- and (ex_mem_rd /= id_ex_rs) ya no necesario por el elseif
			and (mem_wb_rd = id_ex_rs)) 
			then anticipar_a <= b"01"; 
		else 
			anticipar_a <= b"00";
		end if;
		
	-- Anticipar B(Modificara la salida del Mux B que le da el segundo dato a la alu)
		-- La instruccion que esta en la estapa EX/MEM modificara el RT que usara la alu (Riesgo en EX Nro 2)
		if ((ex_mem_regWrite = '1') 
			and (ex_mem_rd /="00000") 
			and (ex_mem_rd = id_ex_rt)) 
			then anticipar_b <= b"10"; 
			
		-- La instruccion que esta en la estapa MEM/WB modificara el RT que usara la alu (Riesgo en MEM Nro 2)				
		elsif ((mem_wb_regWrite = '1')
			and (mem_wb_rd /="00000")
			-- and (ex_mem_rd /= id_ex_rt) ya no necesario por el elseif
			and (mem_wb_rd = id_ex_rt)) 
			then anticipar_b <= b"01"; 
		
		else 
			anticipar_b <= b"00";
		end if;
		
	
	end process;

end Behavioral;