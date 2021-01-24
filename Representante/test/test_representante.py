import pytest

import brownie
import time

PORCENTAJE1 = 10
PORCENTAJE2 = 20
PORCENTAJE3 = 30
TOPE = 2

SALARIO1 = 400
TOPE1 = 3
@pytest.fixture
def representante_contract(representante, accounts):
    yield representante.deploy(PORCENTAJE1,PORCENTAJE2,PORCENTAJE3,TOPE,{'from': accounts[0]})

def test_inicial(representante_contract,accounts):
    assert representante_contract.representante() == accounts[0]
    assert representante_contract.trabajos(1) == PORCENTAJE1
    assert representante_contract.trabajos(2) == PORCENTAJE2
    assert representante_contract.trabajos(3) == PORCENTAJE3
    assert representante_contract.tope() == TOPE

def test_event(representante_contract,accounts):
    representante_contract.contratar(1,{'from':accounts[1]})
    representante_contract.contratar(0,{'from':accounts[2]})
    representante_contract.trabajo_encontrado(accounts[2],SALARIO1 *2,TOPE1,accounts[4],3,{'from':accounts[0]})
    representante_contract.trabajo_encontrado(accounts[1],SALARIO1,TOPE1,accounts[3],1,{'from':accounts[0]})
    
    representante_contract.aceptar_trabajo({'from':accounts[2]})
    
    assert representante_contract.aceptado()
    assert representante_contract.mostrar_salario({'from':accounts[1]}) == SALARIO1
    assert representante_contract.mostrar_salario({'from':accounts[2]}) == SALARIO1 * 2
    time.sleep(4)
    
    tx1 = representante_contract.pagar_trabajo(accounts[1],{'from':accounts[0],'value':SALARIO1})
    tx2 = representante_contract.pagar_trabajo(accounts[2],{'from':accounts[0],'value':SALARIO1*2})
    
    
    
    assert len(tx1.events) == 1
    assert tx1.events[0]['receptor'] == accounts[3]
    assert tx1.events[0]['valor'] == SALARIO1
    assert len(tx2.events) == 2
    assert tx2.events[0]['receptor'] == accounts[0]
    assert tx2.events[0]['valor'] == (SALARIO1*2*PORCENTAJE3 )/100
    assert tx2.events[1]['receptor'] == accounts[2]
    assert tx2.events[1]['valor'] == SALARIO1*2-((SALARIO1*2*PORCENTAJE3 )/100)
    
    representante_contract.cambiar_porcentaje(1,PORCENTAJE2,{'from':accounts[0]}) 
    assert representante_contract.trabajos(1) ==PORCENTAJE2
    
def test_failed_transactions(representante_contract, accounts):
    representante_contract.contratar(2,{'from':accounts[2]})
    
    with brownie.reverts("Tipo de trabajo correcto"):
        representante_contract.contratar(6,{'from':accounts[3]})
    
    with brownie.reverts("Es cliente"):
        representante_contract.trabajo_encontrado(accounts[3],SALARIO1,TOPE1,accounts[4],1,{'from':accounts[0]})
    
    with brownie.reverts("Representante"):
        representante_contract.trabajo_encontrado(accounts[2],SALARIO1,TOPE1,accounts[4],1,{'from':accounts[5]})
    
    with brownie.reverts("Tipo trabajo aceptable"):
        representante_contract.trabajo_encontrado(accounts[2],SALARIO1,TOPE1,accounts[4],1,{'from':accounts[0]})
    
    with brownie.reverts("Es cliente"):
        representante_contract.aceptar_trabajo({'from':accounts[1]})
    
    with brownie.reverts("Es cliente"):
        representante_contract.pagar_trabajo(accounts[1],{'from':accounts[0],'value':SALARIO1*2})    
    
    with brownie.reverts("Es cliente"):
        representante_contract.dejar_representante({'from':accounts[1]})    
    
    with brownie.reverts("Es cliente"):
        representante_contract.cambiar_trabajo(1,{'from':accounts[1]})  
    
    with brownie.reverts("Es cliente"):
        representante_contract.mostrar_salario({'from':accounts[1]}) 
    
    with brownie.reverts("Es cliente"):
        representante_contract.mostrar_tiempo_tope({'from':accounts[1]}) 
        
    with brownie.reverts("Representante"):
        representante_contract.dejar_cliente(accounts[1],{'from':accounts[1]}) 
    
    with brownie.reverts("Es cliente"):
        representante_contract.dejar_cliente(accounts[1],{'from':accounts[0]}) 
        
    with brownie.reverts("Despues de tope o aceptado"):
        representante_contract.pagar_trabajo(accounts[2],{'from':accounts[0],'value':SALARIO1*2})    
    
    representante_contract.trabajo_encontrado(accounts[2],SALARIO1*2,TOPE1,accounts[4],2,{'from':accounts[0]})
    representante_contract.aceptar_trabajo({'from':accounts[2]})
    
    with brownie.reverts("Representante"):
        representante_contract.pagar_trabajo(accounts[2],{'from':accounts[1],'value':SALARIO1*2})    
    
    with brownie.reverts("Valor exacto"):
        representante_contract.pagar_trabajo(accounts[2],{'from':accounts[0],'value':SALARIO1})    
    
    with brownie.reverts("Trabajo valido"):
        representante_contract.cambiar_trabajo(5,{'from':accounts[2]}) 
                                               
    representante_contract.contratar(1,{'from':accounts[1]})
    
    with brownie.reverts("Hay hueco"):
        representante_contract.contratar(1,{'from':accounts[1]})
    
    with brownie.reverts("Representante"):
        representante_contract.cambiar_porcentaje(5,40,{'from':accounts[2]}) 
    
    with brownie.reverts("Trabajo valido"):
        representante_contract.cambiar_porcentaje(5,40,{'from':accounts[0]})
    
    with brownie.reverts("Porcentaje"):
        representante_contract.cambiar_porcentaje(1,400,{'from':accounts[0]})
                                                  
    time.sleep(4)
    with brownie.reverts("Dentro de tiempo"):
        representante_contract.aceptar_trabajo({'from':accounts[2]})
