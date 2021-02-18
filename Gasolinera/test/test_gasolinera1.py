
import pytest

import brownie
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
MAXIMO = 1000

@pytest.fixture
def gasolinera1_contract(gasolinera1, accounts):
    yield gasolinera1.deploy(PRECIO95,PRECIO98,PRECION,PRECIOP,MAXIMO,LITROS,LITROS2,LITROS,LITROS,SEL1,SEL2,SEL3,SEL4,SEL5,SEL6,SEL7,{'from': accounts[0]})

def test_inicial(gasolinera1_contract,accounts):
    assert gasolinera1_contract.empresa()==accounts[0]
    assert gasolinera1_contract.gasolinera("G95") == (LITROS,PRECIO95)
    assert gasolinera1_contract.gasolinera("G98") == (LITROS2,PRECIO98)
    assert gasolinera1_contract.gasolinera("DiN") == (LITROS,PRECION)
    assert gasolinera1_contract.gasolinera("DiP") == (LITROS,PRECIOP)
    assert gasolinera1_contract.maximo() == MAXIMO
    
    assert gasolinera1_contract.seleccion(0) == SEL1
    assert gasolinera1_contract.seleccion(1) == SEL2
    assert gasolinera1_contract.seleccion(2) == SEL3
    assert gasolinera1_contract.seleccion(3) == SEL4
    assert gasolinera1_contract.seleccion(4) == SEL5
    assert gasolinera1_contract.seleccion(5) == SEL6
    assert gasolinera1_contract.seleccion(6) == SEL7
    
    

def test_comprobacion(gasolinera1_contract,accounts):
    assert gasolinera1_contract.precio("G95",{'from':accounts[1]}) == PRECIO95
    assert gasolinera1_contract.precio("G98",{'from':accounts[1]}) == PRECIO98
    assert gasolinera1_contract.precio("DiN",{'from':accounts[1]}) == PRECION
    assert gasolinera1_contract.precio("DiP",{'from':accounts[1]}) == PRECIOP
    
    gasolinera1_contract.echargasolina(1,"G95",0,{'from':accounts[1],'value':10})
    gasolinera1_contract.parar(1,1,False,{'from':accounts[1]})
    
    
def test_failed_transactions(gasolinera1_contract, accounts):
    with brownie.reverts("Bien escrito"):
        gasolinera1_contract.echargasolina(1,"G58",0,{'from':accounts[1],'value':10})
    
    with brownie.reverts("Seleccion valida"):
        gasolinera1_contract.echargasolina(1,"G95",9,{'from':accounts[1],'value':10})
    
    with brownie.reverts("Precio valido"):
        gasolinera1_contract.echargasolina(1,"G98",0,{'from':accounts[1],'value':18})
       
    with brownie.reverts("Hay litros suficientes"):
        gasolinera1_contract.echargasolina(1,"G98",6,{'from':accounts[1],'value':100})
    
    with brownie.reverts("Numero calle correcto"):
        gasolinera1_contract.parar(2,10,True,{'from':accounts[1]})
        
    with brownie.reverts("El surtidor se esta usando"):
        gasolinera1_contract.parar(1,10,True,{'from':accounts[1]})
    
    with brownie.reverts("Empresa"):
        gasolinera1_contract.surtir(12,"GNT",{'from':accounts[1]})  
        
    with brownie.reverts("Bien escrito"):
        gasolinera1_contract.surtir(12,"GNT",{'from':accounts[0]}) 
        
    with brownie.reverts("Entra"):
        gasolinera1_contract.surtir(1000,"G98",{'from':accounts[0]}) 
    
    with brownie.reverts("Empresa"):
        gasolinera1_contract.cambiar_precio("G90",12,{'from':accounts[1]}) 
        
    with brownie.reverts("Bien escrito"):
        gasolinera1_contract.cambiar_precio("G90",12,{'from':accounts[0]})     
    
    with brownie.reverts("Distinto precio"):
        gasolinera1_contract.cambiar_precio("G95",10,{'from':accounts[0]}) 
    
    with brownie.reverts("Positivo"):
        gasolinera1_contract.cambiar_precio("G95",0,{'from':accounts[0]})
    
    with brownie.reverts("Empresa"):
        gasolinera1_contract.cambiar_seleccion(1,40,{'from':accounts[1]})
    
    with brownie.reverts("En el rango"):
        gasolinera1_contract.cambiar_seleccion(9,40,{'from':accounts[0]})
       
    gasolinera1_contract.echargasolina(1,"G95",1,{'from':accounts[1],'value':20})
    
    with brownie.reverts("No se estan usando"):
        gasolinera1_contract.echargasolina(1,"G95",0,{'from':accounts[1],'value':10})
    
    with brownie.reverts("Esta lleno o tope"):
        gasolinera1_contract.parar(1,1,False,{'from':accounts[1]})
        
    
    gasolinera1_contract.parar(1,2,False,{'from':accounts[1]})
