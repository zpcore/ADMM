package admmTestbenchGen;

import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.util.Random;

public class Main {

	public static void main(String[] args) throws FileNotFoundException, UnsupportedEncodingException {
		int s1=5,s2=7,k=4;
		int numbram=0;
		int addr=0;
		PrintWriter writer_hex = new PrintWriter("ADMM_TEST_HEX", "UTF-8");
		PrintWriter writer_flo = new PrintWriter("ADMM_TEST_FLOAT", "UTF-8");
		PrintWriter writer_testbench = new PrintWriter("ADMM_TESTBENCH", "UTF-8");
		if(k>s2){
			for(int i=0;i<s1;i++){
				for(int j=0;j<s2;j++){
					float rand=(float)randomInRange(1,10);
					int bits = Float.floatToIntBits(rand);
					String hexData=Integer.toString(bits,16);
					writer_hex.print(hexData+" ");
					writer_flo.print(rand+" ");
					
					writer_testbench.println("	wait for CLK_period;");
					writer_testbench.println("	NumBRAM <= std_logic_vector(to_unsigned("+numbram+", NumBRAM'length));");
					writer_testbench.println("	ADDRBRAM <= std_logic_vector(to_unsigned("+addr+",ADDRBRAM'length));");
					writer_testbench.println("	MATData <= "+ "x\""+hexData+"\";");
					writer_testbench.println();
					numbram=numbram==k-1?0:numbram+1;
				}
				
				for(int j=s2;j<k;j++){
					
					writer_testbench.println("	wait for CLK_period;");
					writer_testbench.println("	NumBRAM <= std_logic_vector(to_unsigned("+numbram+", NumBRAM'length));");
					writer_testbench.println("	ADDRBRAM <= std_logic_vector(to_unsigned("+addr+",ADDRBRAM'length));");
					writer_testbench.println("	MATData <= "+ "x\"00000000\";");
					writer_testbench.println();
					numbram=numbram==k?0:numbram+1;
				}
				numbram=0;
				addr++;
				writer_hex.println();
				writer_flo.println();
			}	
		}else{
			
			for(int i=0;i<s1;i++){
				int colCount=1;
				while(colCount<s2){
					for(int j=0;j<k;j++){
						if(colCount>s2){
							writer_testbench.println("	wait for CLK_period;");
							writer_testbench.println("	NumBRAM <= std_logic_vector(to_unsigned("+numbram+", NumBRAM'length));");
							writer_testbench.println("	ADDRBRAM <= std_logic_vector(to_unsigned("+addr+",ADDRBRAM'length));");
							writer_testbench.println("	MATData <= "+ "x\"00000000\";");
							writer_testbench.println();
						}else{
							float rand=(float)randomInRange(1,10);
							int bits = Float.floatToIntBits(rand);
							String hexData=Integer.toString(bits,16);
							writer_hex.print(hexData+" ");
							writer_flo.print(rand+" ");
							writer_testbench.println("	wait for CLK_period;");
							writer_testbench.println("	NumBRAM <= std_logic_vector(to_unsigned("+numbram+", NumBRAM'length));");
							writer_testbench.println("	ADDRBRAM <= std_logic_vector(to_unsigned("+addr+",ADDRBRAM'length));");
							writer_testbench.println("	MATData <= "+ "x\""+hexData+"\";");
							writer_testbench.println();
						}
						
						numbram=numbram==k-1?0:numbram+1;
						colCount++;
					}
					addr++;
				}
				writer_hex.println();
				writer_flo.println();
			}
			
		}
		
		writer_hex.close();
		writer_flo.close();
		writer_testbench.close();
	}
	
	public static double randomInRange(double min, double max) {
		Random random = new Random();
		return (random.nextDouble() * (max-min)) + min;
	}

}
