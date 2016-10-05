package admmTestbenchGen;

import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.util.Random;

public class Main {

	public static void main(String[] args) throws FileNotFoundException, UnsupportedEncodingException {
		
		int ROW=9,COL=11,numMul=16;
		int numbram=0;
		int addr=0;
		PrintWriter writer_hex = new PrintWriter("ADMM_TEST_HEX", "UTF-8");
		PrintWriter writer_flo = new PrintWriter("ADMM_TEST_FLOAT", "UTF-8");
		PrintWriter writer_testbench = new PrintWriter("ADMM_TESTBENCH", "UTF-8");
		if(numMul>COL){
			for(int i=0;i<ROW;i++){
				for(int j=0;j<COL;j++){
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
					numbram=numbram==numMul-1?0:numbram+1;
				}
				
				for(int j=COL;j<numMul;j++){
					
					writer_testbench.println("	wait for CLK_period;");
					writer_testbench.println("	NumBRAM <= std_logic_vector(to_unsigned("+numbram+", NumBRAM'length));");
					writer_testbench.println("	ADDRBRAM <= std_logic_vector(to_unsigned("+addr+",ADDRBRAM'length));");
					writer_testbench.println("	MATData <= "+ "x\"00000000\";");
					writer_testbench.println();
					numbram=numbram==numMul?0:numbram+1;
				}
				numbram=0;
				addr++;
				writer_hex.println();
				writer_flo.println();
			}	
		}else{//reduce
			
			for(int i=0;i<ROW;i++){
				for(int k=0;k< numMul*java.lang.Math.ceil((float)COL/numMul);k++){
					if(k<COL){
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
					}else{
					
						writer_testbench.println("	wait for CLK_period;");
						writer_testbench.println("	NumBRAM <= std_logic_vector(to_unsigned("+numbram+", NumBRAM'length));");
						writer_testbench.println("	ADDRBRAM <= std_logic_vector(to_unsigned("+addr+",ADDRBRAM'length));");
						writer_testbench.println("	MATData <= "+ "x\"00000000\";");
						writer_testbench.println();
					}
					if(numbram==numMul-1){
						addr++;
						numbram=0;
					}else{
						numbram++;
					}	
					if(k==COL-1){
						writer_hex.println();
						writer_flo.println();
					}
				
				}
				
			}
			
		}
		
		writer_hex.close();
		writer_flo.close();
		writer_testbench.close();
		
		//generate QR testbench 
		//genQR();
	}
	
	public static double randomInRange(double min, double max) {
		Random random = new Random();
		return (random.nextDouble() * (max-min)) + min;
	}

	
	
	public static void genQR() throws FileNotFoundException, UnsupportedEncodingException{
		PrintWriter QR_hex = new PrintWriter("QR_HEX", "UTF-8");
		PrintWriter QR_flo = new PrintWriter("QR_flo", "UTF-8");
		for(int i=0;i<100;i++){
			float rand=(float)randomInRange(0.1,2);
			int bits = Float.floatToIntBits(rand);
			String hexData=Integer.toString(bits,16);
			QR_flo.println(rand+" ");
			
			QR_hex.println("	wait for 2*CLK_period;");
			QR_hex.println("	NEW_QR_RDY <= "+"\'1\';");
			QR_hex.println("	QR <= "+ "x\"" + hexData+"\";");
			QR_hex.println("	wait for CLK_period;");
			QR_hex.println("	NEW_QR_RDY <= "+"\'0\';");
			QR_hex.println();
		}
		QR_hex.close();
		QR_flo.close();
	}
}
