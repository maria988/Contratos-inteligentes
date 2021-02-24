
import pytest

import brownie
import time
PRECIO95 = 10
PRECIO98 = 15
PRECION = 12
PRECIOP = 10
LITROS = 900
LITROS2 = 2
SEL1 = 10
SEL2 = 20
SEL3 = 30
SEL4 = 40
SEL5 = 50
SEL6 = 60
SEL7 = 100
APUNTOS = 10
MAXIMO = 1000
LITROSGRATIS = 10
PUNTOS = 100

@pytest.fixture
def litros_contract(litrosgratis, accounts):
    yield litrosgratis.deploy(PRECIO95,PRECIO98,PRECION,PRECIOP,MAXIMO,LITROS,LITROS2,LITROS,LITROS,SEL1,SEL2,SEL3,SEL4,SEL5,SEL6,SEL7,PUNTOS,LITROSGRATIS,APUNTOS,{'from': accounts[0]})

def test_inicial(litros_contract,accounts):
    assert litros_contract.empresa()==accounts[0]
    assert litros_contract.gasolinera("G95") == (LITROS,PRECIO95)
    assert litros_contract.gasolinera("G98") == (LITROS2,PRECIO98)
    assert litros_contract.gasolinera("DiN") == (LITROS,PRECION)
    assert litros_contract.gasolinera("DiP") == (LITROS,PRECIOP)
    assert litros_contract.maximo() == MAXIMO
    
    assert litros_contract.seleccion(1) == SEL1
    assert litros_contract.seleccion(2) == SEL2
    assert litros_contract.seleccion(3) == SEL3
    assert litros_contract.seleccion(4) == SEL4
    assert litros_contract.seleccion(5) == SEL5
    assert litros_contract.seleccion(6) == SEL6
    assert litros_contract.seleccion(7) == SEL7
    
    assert litros_contract.puntos() == PUNTOS
    assert litros_contract.litrosgratis() == LITROSGRATIS
    assert litros_contract.apuntos() == APUNTOS
    

def test_comprobacion(litros_contract,accounts):
    assert litros_contract.precio("G95",{'from':accounts[1]}) == PRECIO95
    assert litros_contract.precio("G98",{'from':accounts[1]}) == PRECIO98
    assert litros_contract.precio("DiN",{'from':accounts[1]}) == PRECION
    assert litros_contract.precio("DiP",{'from':accounts[1]}) == PRECIOP
    
    litros_contract.nuevocliente({'from':accounts[1]})
    litros_contract.echargasolina(1,"G95",1,{'from':accounts[1],'value':10})
    litros_contract.parar(1,1,False)
    
    
def test_failed_transactions(litros_contract, accounts):
    with brownie.reverts("Bien escrito"):
        litros_contract.echargasolina(1,"G58",1,{'from':accounts[1],'value':10})
    
    with brownie.reverts("Seleccion valida"):
        litros_contract.echargasolina(1,"G95",9,{'from':accounts[1],'value':10})
    
    with brownie.reverts("Precio valido"):
        litros_contract.echargasolina(1,"G98",1,{'from':accounts[1],'value':18})
       
    with brownie.reverts("Hay litros suficientes"):
        litros_contract.echargasolina(1,"G98",7,{'from':accounts[1],'value':100})
    
    with brownie.reverts("El surtidor se esta usando"):
        litros_contract.parar(1,10,True,{'from':accounts[1]})
    
    with brownie.reverts("Empresa"):
        litros_contract.surtir(12,"GNT",{'from':accounts[1]})  
        
    with brownie.reverts("Bien escrito"):
        litros_contract.surtir(12,"GNT",{'from':accounts[0]}) 
        
    with brownie.reverts("Entra"):
        litros_contract.surtir(1000,"G98",{'from':accounts[0]}) 
    
    with brownie.reverts("Empresa"):
        litros_contract.cambiar_precio("G90",12,{'from':accounts[1]}) 
        
    with brownie.reverts("Bien escrito"):
        litros_contract.cambiar_precio("G90",12,{'from':accounts[0]})     
    
    with brownie.reverts("Distinto precio"):
        litros_contract.cambiar_precio("G95",10,{'from':accounts[0]}) 
    
    with brownie.reverts("Positivo"):
        litros_contract.cambiar_precio("G95",0,{'from':accounts[0]})
    
    with brownie.reverts("Empresa"):
        litros_contract.cambiar_seleccion(1,40,{'from':accounts[1]})
    
    with brownie.reverts("Positiva"):
        litros_contract.cambiar_seleccion(0,40,{'from':accounts[0]})
    
    litros_contract.nuevocliente({'from':accounts[1]})    
    litros_contract.echargasolina(1,"G95",2,{'from':accounts[1],'value':20})
    
    with brownie.reverts("No se estan usando"):
        litros_contract.echargasolina(1,"G95",1,{'from':accounts[1],'value':10})
    
    with brownie.reverts("Esta lleno o tope"):
        litros_contract.parar(1,1,False,{'from':accounts[1]})
        
    
    litros_contract.parar(1,2,False,{'from':accounts[1]})
    
