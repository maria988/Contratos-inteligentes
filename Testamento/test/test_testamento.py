import pytest

import brownie
import time

PRECIO = 50
DURACION = 5

HERENCIA = 150

@pytest.fixture
def testamento_contract(testamento, accounts):
    yield testamento.deploy(accounts[1],PRECIO,DURACION,accounts[6],{'from': accounts[0]})

def test_inicial(testamento_contract,accounts):
    assert testamento_contract.empresa() == accounts[0]
    assert testamento_contract.cliente() == accounts[1]
    assert testamento_contract.precio() == PRECIO
    assert testamento_contract.duracion() == DURACION
    assert testamento_contract.estado() == accounts[6]

def test_event(testamento_contract,accounts):
    testamento_contract.pagar(HERENCIA *5,{'from':accounts[1],'value':PRECIO +HERENCIA *5})
    testamento_contract.anadir_herederos(accounts[2],HERENCIA,{'from':accounts[1]})
    testamento_contract.anadir_herederos(accounts[3],HERENCIA,{'from':accounts[1]})
    testamento_contract.anadir_herederos(accounts[4],HERENCIA,{'from':accounts[1]})
    testamento_contract.anadir_herederos(accounts[5],HERENCIA,{'from':accounts[1]})
    
    testamento_contract.cambiar_herencia(0,2*HERENCIA,{'from':accounts[1] })
    
    testamento_contract.inicializar_herencia({'from':accounts[0]})
    
    testamento_contract.firmar_herencia({'from':accounts[2]})
    testamento_contract.firmar_herencia({'from':accounts[4]})
    testamento_contract.firmar_herencia({'from':accounts[5]})
    
    time.sleep(6)
    assert testamento_contract.saber_herencia(accounts[2])== 2*HERENCIA
    tx1 = testamento_contract.cobrar_herencia({'from':accounts[0]})
    
    assert len(tx1.events) == 5
    assert tx1.events[0]['destinatario'] == accounts[2]
    assert tx1.events[0]['valor'] == HERENCIA *2
    assert tx1.events[1]['destinatario'] == accounts[4]
    assert tx1.events[1]['valor'] == HERENCIA
    assert tx1.events[2]['destinatario'] == accounts[5]
    assert tx1.events[2]['valor'] == HERENCIA 
    assert tx1.events[3]['destinatario'] == accounts[0]
    assert tx1.events[3]['valor'] ==  PRECIO
    assert tx1.events[4]['destinatario'] == accounts[6]
    assert tx1.events[4]['valor'] ==  HERENCIA
    
def test_failed_transactions(testamento_contract, accounts):
    
    with brownie.reverts("Precio exacto"):
        testamento_contract.pagar(HERENCIA *5,{'from':accounts[1],'value':PRECIO +HERENCIA *4})
    
    with brownie.reverts("Cliente"):
        testamento_contract.pagar(HERENCIA *5,{'from':accounts[4],'value':PRECIO +HERENCIA * 5})
        
    with brownie.reverts("Pagado"):
        testamento_contract.anadir_herederos(accounts[2],HERENCIA,{'from':accounts[1]})
    
    with brownie.reverts("Pagado"):
        testamento_contract.cambiar_herencia(1,HERENCIA,{'from':accounts[1]})
    
    testamento_contract.pagar(HERENCIA *5,{'from':accounts[1],'value':PRECIO +HERENCIA * 5})
    
    with brownie.reverts("Cliente"):
        testamento_contract.anadir_herederos(accounts[2],HERENCIA,{'from':accounts[4]})
    
    with brownie.reverts("Suficiente"):
        testamento_contract.anadir_herederos(accounts[2],HERENCIA*7,{'from':accounts[1]})
    
    with brownie.reverts("Cliente"):
        testamento_contract.cambiar_herencia(2,HERENCIA,{'from':accounts[3]})
        
    with brownie.reverts("Numero valido"):
        testamento_contract.cambiar_herencia(2,HERENCIA,{'from':accounts[1]})
    
    testamento_contract.anadir_herederos(accounts[2],HERENCIA,{'from':accounts[1]})
    
    with brownie.reverts("Suficiente"):
        testamento_contract.cambiar_herencia(0,HERENCIA*9,{'from':accounts[1]})
    
    with brownie.reverts("Empresa"):
        testamento_contract.inicializar_herencia({'from':accounts[3]})
    
    with brownie.reverts("Ha fallecido"):
        testamento_contract.firmar_herencia({'from':accounts[1]})
    
    with brownie.reverts("Ha fallecido"):
        testamento_contract.cobrar_herencia({'from':accounts[1]})
        
    testamento_contract.inicializar_herencia({'from':accounts[0]})
    
    with brownie.reverts("No ha fallecido"):
        testamento_contract.inicializar_herencia({'from':accounts[0]})
    
    with brownie.reverts("Valor positivo"):
        testamento_contract.firmar_herencia({'from':accounts[1]})
    
    with brownie.reverts("Tope pasado"):
        testamento_contract.cobrar_herencia({'from':accounts[1]})
        
    time.sleep(6)
    
    with brownie.reverts("Dentro de tiempo"):
        testamento_contract.firmar_herencia({'from':accounts[2]})
