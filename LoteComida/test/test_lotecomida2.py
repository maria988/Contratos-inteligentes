
import pytest

import brownie
import time

LOTE = "A234P"
PRECIO = 100
CANTIDAD = 3
DURACION = 4

@pytest.fixture
def lote_comida2_contract(lotecomida2, accounts):
    yield lotecomida2.deploy(LOTE,DURACION,PRECIO,CANTIDAD,{'from': accounts[0]})

def test_inicial(lote_comida2_contract,accounts):
    assert lote_comida2_contract.lote() == LOTE
    assert lote_comida2_contract.empresa() == accounts[0]
    assert lote_comida2_contract.precio() == PRECIO
    assert lote_comida2_contract.cantidad() == CANTIDAD

def test_events1(lote_comida2_contract,accounts):
    lote_comida2_contract.comprar(1,{'from':accounts[1],'value':100})
    lote_comida2_contract.comprar(2,{'from':accounts[2],'value':200})
    tx1 = lote_comida2_contract.mensaje_aviso("Las latas estan hinchadas",{'from':accounts[2]})
    tx2 = lote_comida2_contract.retirar_del_mercado("Las latas tienen salmonelosis",{'from':accounts[0]})
    assert len(tx1.events) == 1
    assert tx1.events[0]['receptor'] == accounts[0]
    assert tx1.events[0]['lote'] == LOTE
    assert tx1.events[0]['frase'] == "Las latas estan hinchadas"
    assert len(tx2.events) == 2
    assert tx2.events[0]['receptor'] == accounts[1]
    assert tx2.events[0]['lote'] == LOTE
    assert tx2.events[0]['frase'] == "Las latas tienen salmonelosis"
    assert tx2.events[1]['receptor'] == accounts[2]
    lote_comida2_contract.fin({'from':accounts[0]})

def test_events2(lote_comida2_contract,accounts):
    lote_comida2_contract.comprar(1,{'from':accounts[1],'value':100})
    lote_comida2_contract.comprar(2,{'from':accounts[2],'value':200})
    tx1 = lote_comida2_contract.mensaje_aviso("Las chapas estan torcidas",{'from':accounts[2]})
    tx2 = lote_comida2_contract.aviso_a_clientes("Las chapas estan torcidas",{'from':accounts[0]})
    assert len(tx1.events) == 1
    assert tx1.events[0]['receptor'] == accounts[0]
    assert tx1.events[0]['lote'] == LOTE
    assert tx1.events[0]['frase'] == "Las chapas estan torcidas"
    assert len(tx2.events) == 2
    assert tx2.events[0]['receptor'] == accounts[1]
    assert tx2.events[0]['lote'] == LOTE
    assert tx2.events[1]['frase'] == "Las chapas estan torcidas"
    assert tx2.events[1]['receptor'] == accounts[2]
    time.sleep(4)
    lote_comida2_contract.fin({'from':accounts[0]})
    
def test_failed_transactions(lote_comida2_contract, accounts):
    
    with brownie.reverts("Precio exacto"):
        lote_comida2_contract.comprar(1,{'from':accounts[1],'valor':10})
    
    with brownie.reverts("Ha comprado"):
        lote_comida2_contract.mensaje_aviso("Las latas estan hinchadas",{'from':accounts[2]})
    
    with brownie.reverts("Empresa"):
        lote_comida2_contract.retirar_del_mercado("Las latas estan hinchadas",{'from':accounts[2]})
    
    with brownie.reverts("Avisado"):
        lote_comida2_contract.retirar_del_mercado("Las latas estan hinchadas",{'from':accounts[0]})
    
    with brownie.reverts("Empresa"):
        lote_comida2_contract.aviso_a_clientes("Las latas estan hinchadas",{'from':accounts[2]})
    
    with brownie.reverts("Avisado"):
        lote_comida2_contract.aviso_a_clientes("Las latas estan hinchadas",{'from':accounts[0]})
    
    with brownie.reverts("Empresa"):
        lote_comida2_contract.fin({'from':accounts[2]})
    
    with brownie.reverts("Avisado o caducado"):
        lote_comida2_contract.fin({'from':accounts[0]})
    
    lote_comida2_contract.comprar(3,{'from':accounts[2],'value':3*PRECIO})
    
    with brownie.reverts("Hay suficientes"):
        lote_comida2_contract.comprar(1,{'from':accounts[2],'value':PRECIO})
        
    time.sleep(4)   
    with brownie.reverts("Antes de caducarse"):
        lote_comida2_contract.comprar(1,{'from':accounts[2],'value':100})   
    
    with brownie.reverts("Antes de caducarse"):
        lote_comida2_contract.mensaje_aviso("Las latas estan hinchadas",{'from':accounts[2]})
