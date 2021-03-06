# MIPS Segmentado 

## Trabajo Práctico Final

### Arquitectura de Computadoras 1

#### Universidad Nacional de Tres de Febrero 

## Drive del Informe

https://drive.google.com/drive/folders/1waicHrNDdCIElkje7xlGZl1lWKSU62F0?usp=sharing

## TOC del Informe 

 1. Enunciado
 
    Unificar parte 1 y 2
 2. Introducción

    Tipos de instrucciones MIPS. Instrucciones tipo I.
    
    Riesgos de Datos. Forwarding.
    
    Riesgos de Control. Jump.
    
 3. Recursos
 
    Instalación del entorno de desarrollo.
    
    Configuración del entorno de desarrollo.
    
    Copia del repositorio.
    
    Guía para la simulación.
    
 3. Diseño de la implementación
    1. Extensión para instrucciones I.

       Elaborar datapath. Descripción.
    2. Extensión para instrucción LUI.

       Elaborar datapath. Descripción.
    3. Extensión para instruccion Jump.

       Elaborar datapath. Descripción.
    4. Extensión con Forwarding Unit.

       Elaborar datapath. Descripción.

 4. Análisis de la implementación 
    1. Extensión para instrucciones I.

       Fragmento de simulación con instrucciones del programa y señales relevantes. Descripción.
    1. Extensión para instruccion LUI.

       Fragmento de simulación con instrucciones del programa y señales relevantes. Descripción.
    3. Extensión para instruccion Jump.

       Fragmento de simulación con instrucciones del programa y señales relevantes. Descripción.
    4. Extensión para Forwarding.

       Fragmento de simulación con instrucciones del programa y señales relevantes. Descripción.

 5. Conclusiones 

 6. Referencias
 
    Bibliografía en diapositivas.
 
    Páginas de las aplicaciones.

Boceto para recursos:
- instalar GHDL. Agregar directorio de instalación al Path del sistema.
- instalar Python. Agregar directorio de instalacion y Python\Lib al Path del sistema. Agregar variable del sistema PYTHONPATH con directorio de instalación.
- instalar Eclipse. Coincidir con versión de Java.
- instalar plugin ZamiaCAD de Eclipse.
- clonar repositorio 
- crear proyecto ZamiaCAD (verificar sin errores en consola ZamiaCAD)
- importar archivos (opción General->Filesystem)
- editar BuildPath.txt con processor_tb(arquitectura) (verificar sin errores en consola ZamiaCAD)
- agregar configuración External Tool con build.bat (usar browse proyect directory)
- agregar configuración Run as... en Zamia con VCD en simulador y processor_tb.vcd en archivo.
- ejecutar External Tool (en la consola aparecerá el paso a paso del GHDL)
- ejecutar Run as... (debe aparecer la solapa de simulación)
- elegir las señales a inspeccionar  (opción trace con ojo de icono)
