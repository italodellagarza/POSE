import sys
import os

def show_interface():
    print("Qual metodo voce deseja utilizar?")
    print("1. Modelo matematico")
    print("2. Heurisitca")
    print("3. Modelo SETI-UFLA")
    print("0. Sair")


def read_option():
    show_interface()
    x = int(input())
    return x

def run_option(x):
    if(x == 1):
        print("Insira o local do arquivo de entrada (a partir do diretório atual)")
        input_file = input()
        print("Insira o local do arquivo de saida (a partir do diretório atual)")
        output_file = input()
        print("Digite a capacidade por horário")
        schedule_capacity = input()
        print("Digite a capacidade por dia")
        date_capacity = input()
        command_execution = ""
        command_execution += julia_location + " ./modelo/src/Pose.jl" + " " 
        command_execution += input_file + " "
        command_execution += "./modelo/results/res_temp.txt" + " " 
        command_execution += schedule_capacity + " " + date_capacity
        print(command_execution)
        os.system(command_execution)

        command_verifier = ""
        command_verifier += "python3" + " " + "./verifier.py" + " "
        command_verifier += "./modelo/results/res_temp.txt" + " "
        command_verifier += input_file + " " + output_file
        print(command_verifier)
        os.system(command_verifier)

        return
    if(x == 2):
        print("Insira o local do arquivo de entrada (a partir do diretório atual)")
        input_file = input()
        print("Insira o local do arquivo de saida (a partir do diretório atual)")
        output_file = input()
        print("Digite a capacidade por horário")
        schedule_capacity = input()
        print("Digite a capacidade por dia")
        date_capacity = input()
        command_execution = ""
        command_execution += julia_location + " ./heuristica/src/Pose.jl" + " " 
        command_execution += input_file + " "
        command_execution += "./heuristica/results/res_temp.txt" + " " 
        command_execution += schedule_capacity + " " + date_capacity
        print(command_execution)
        os.system(command_execution)

        command_verifier = ""
        command_verifier += "python3" + " " + "./verifier.py" + " "
        command_verifier += "./heuristica/results/res_temp.txt" + " "
        command_verifier += input_file + " " + output_file
        print(command_verifier)
        os.system(command_verifier)
        return
    if(x == 3):
        print("Insira o local do arquivo de entrada (a partir do diretório atual)")
        input_file = input()
        print("Insira o local do arquivo de saida (a partir do diretório atual)")
        output_file = input()
        print("Digite a capacidade por horário")
        schedule_capacity = input()
        print("Digite a capacidade por dia")
        date_capacity = input()
        command_execution = ""
        command_execution += julia_location + " ./modelo_seti/src/Pose.jl" + " " 
        command_execution += input_file + " "
        command_execution += "./modelo_seti/results/res_temp.txt" + " " 
        command_execution += schedule_capacity + " " + date_capacity
        print(command_execution)
        os.system(command_execution)

        command_verifier = ""
        command_verifier += "python3" + " " + "./modelo_seti/verifier_seti.py"
        command_verifier += " " + "./modelo_seti/results/res_temp.txt" + " "
        command_verifier += input_file + " " + output_file
        print(command_verifier)
        os.system(command_verifier)
        return
    return

if __name__ == "__main__":
    if(len(sys.argv) < 2):
        print("Exemplo de execucao:")
        print("python3 scheduler.py <local do julia>")

    julia_location = sys.argv[1]
    x = read_option()
    while(x > 0):
        run_option(x)
        x = read_option()

# ./modelo/datafiles/ultrapequenino.txt
# ./heuristica/datafiles/ultrapequenino.txt
# ./modelo_seti/datafiles/doubleultrapequenino.txt

# ~/julia-1.1.0/bin/julia