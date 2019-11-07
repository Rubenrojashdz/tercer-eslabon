%% Limpia la memoria de variables
clear all
close all
clc
%% Cierra y elimina cualquier objeto de tipo serial 
if ~isempty(instrfind)
    fclose(instrfind);
    delete(instrfind);
end
%% Creación de un objeto tipo serial
arduino = serial('COM3','BaudRate',9600);
fopen(arduino);
if arduino.status == 'open'
    disp('Arduino conectado correctamente');
else
    disp('No se ha conectado el arduino');
    return
end
%% Configuración de las longitudes del brazo
prompt = 'Introducir el valor L1:';
L1 = input (prompt);
prompt = 'Introducir el valor L2:';
L2 = input (prompt);
prompt = 'Introducir el valor L3:';
L3 = input (prompt);

%% Definición de los parametros de Denavit-Hartenberg
d1 = L1;
d2 = 0;
d3 = 0;
a1 = 0;
a2 = L2;
a3 = L3;
alpha_1 = 90;
alpha_2 = 0;
alpha_3 = 0;
alpha_1_rad = deg2rad(alpha_1);
alpha_2_rad = deg2rad(alpha_2);
alpha_3_rad = deg2rad(alpha_3);
%% Formula para convertir a grados
grado=180/3.1416;
%% Definición del punto incial
p1 =[0 0 0];

while 1
    clf
    printAxis();
%% Obtiene los valores del Arduino y mediante la formula se tiene su dimecion de cada uno de sus  grados
    valor_con_offset = fscanf(arduino,'%d,%d,%d´');
    theta1_deg = ((valor_con_offset(1))-512)*130/512;
    theta1_rad = deg2rad(theta1_deg);
    valor_grados= theta1_rad *grado; 
    disp('Longitud del primer eslabon en grados:')
    disp(valor_grados)
    theta2_deg = ((valor_con_offset(2))-512)*130/512;
    theta2_rad = deg2rad(theta2_deg);
    valor_grado2= theta2_rad *grado; 
    disp('Longitud del segundo eslabon en grados:')
    disp(valor_grado2)
    theta3_deg = ((valor_con_offset(3))-512)*130/512;
    theta3_rad = deg2rad(theta3_deg);
    valor_grado3= theta3_rad *grado; 
    disp('Longitud del tercer eslabon en grados:')
    disp(valor_grado3)
%% Desarrollo de las matrices
    Rotz = [cos(theta1_rad) -sin(theta1_rad) 0 0; sin(theta1_rad) cos(theta1_rad) 0 0; 0 0 1 0; 0 0 0 1];
    A1 = dhParameters(theta1_rad,d1,a1,alpha_1_rad);
    A2 = dhParameters(theta2_rad,d2,a2,alpha_2_rad);
    A3 = dhParameters(theta3_rad,d3,a3,alpha_3_rad);
    A12 = A1*A2;
    A123 = A1*A2*A3; 
%% Se indica los distintos puntos que tendrá el brazo
    p1 = [0 0 0]';
    p2 = A1(1:3,4);
    p3 = A12(1:3,4);
    p4 = A123(1:3,4);
%% Configuración del grosor y color que tendrá cada eslabon del brazo
    printLink(p1,p2);
    printLink(p2,p3);
    printLink(p3,p4);
%% Configuración de los ejes de referencia que tendrá el brazo los cuales son los que nos indica en que eje se rotará
    printMiniAxes(p1,Rotz);
    printMiniAxes(p2,A12);
    printMiniAxes(p3,A123);
    printMiniAxes(p4,A123);
    view(30,30);
    grid on
    pause(0.01);
 end
%% Cierre de puertos
fclose(arduino);
delete(arduino);
clear all; 

