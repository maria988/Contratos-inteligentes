import pytest

import brownie
import time

TASAS = 50
REVISION = 5
NUMEROCHIP = "1234567DJP"
NUMEROCHIP2 = "0998749HHJ"
@pytest.fixture
def adopcion_contract(adopcion, accounts):
    yield adopcion.deploy(REVISION,NUMEROCHIP,accounts[1],TASAS,{'from': accounts[0]})

def test_inicial(adopcion_contract,accounts):
    assert adopcion_contract.protectora() == accounts[0]
    assert adopcion_contract.veterinario() == accounts[1]
    assert adopcion_contract.tasas() == TASAS
    assert adopcion_contract.tiempo_revision() == REVISION
    assert adopcion_contract.microchip() == NUMEROCHIP

def test_funcional(adopcion_contract,accounts):
    adopcion_contract.adoptar("Calle_Norte,7,Toledo","659452900","Clara","Martin",{'from':accounts[4],'value':TASAS})
    assert adopcion_contract.consultar_adoptado()
    adopcion_contract.cambio_telefono("925486253",NUMEROCHIP,{'from':accounts[4]})
    assert ("Clara","Martin","Calle_Norte,7,Toledo","925486253") == adopcion_contract.consultar_datos({'from':accounts[0]})
    adopcion_contract.cambio_veterinario(accounts[3],NUMEROCHIP,{'from':accounts[4]})
    assert adopcion_contract.veterinario() == accounts[3]
    adopcion_contract.ceder(NUMEROCHIP,{'from':accounts[4]})
    adopcion_contract.dar_baja(NUMEROCHIP,{'from':accounts[3]})
    
def test_failed_transactions(adopcion_contract, accounts):
    
    with brownie.reverts("Tasas exactas"):
        adopcion_contract.adoptar("Calle_Norte,7,Toledo","659452900","Clara","Martín_Jimenez",{'from':accounts[4],'value':TASAS * 2})
    
    with brownie.reverts("Adoptado"):
        adopcion_contract.vacunar(False,False,NUMEROCHIP,{'from':accounts[1]})
    
    with brownie.reverts("Adoptado"):
        adopcion_contract.revision(False, NUMEROCHIP,{'from':accounts[0]})
    
    with brownie.reverts("Adoptado"):
        adopcion_contract.ceder(NUMEROCHIP,{'from':accounts[6]})
    
    with brownie.reverts("Adoptado"):
        adopcion_contract.cambio_domicilio("Paseo_Husares,14",NUMEROCHIP2,{'from':accounts[6]})
     
    with brownie.reverts("Adoptado"):
        adopcion_contract.cambio_telefono("925486253",NUMEROCHIP2,{'from':accounts[6]})
     
    adopcion_contract.adoptar("Calle_Norte,7,Toledo","659452900","Clara","Martín_Jimenez",{'from':accounts[4],'value':TASAS})
    
    with brownie.reverts("No adoptado"):
        adopcion_contract.adoptar("Calle_Rosales,5,Jaen","634826799","Javier","Bueno_Marchan",{'from':accounts[2],'value':TASAS})
    
    with brownie.reverts("Veterinario"):
        adopcion_contract.vacunar(False,False,NUMEROCHIP,{'from':accounts[2]})
    
    with brownie.reverts("Microchip correcto"):
        adopcion_contract.vacunar(False,False,NUMEROCHIP2,{'from':accounts[1]})
    
    with brownie.reverts("Protectora"):
        adopcion_contract.revision(False, NUMEROCHIP,{'from':accounts[3]})
        
    with brownie.reverts("Superior al tope"):
        adopcion_contract.revision(False, NUMEROCHIP,{'from':accounts[0]})
    
    with brownie.reverts("Microchip correcto"):
        adopcion_contract.ceder(NUMEROCHIP2,{'from':accounts[6]})
    
    with brownie.reverts("Dueno"):
        adopcion_contract.ceder(NUMEROCHIP,{'from':accounts[6]})
    
    with brownie.reverts("Veterinario"):
        adopcion_contract.dar_baja(NUMEROCHIP,{'from':accounts[0]})
    
    with brownie.reverts("Microchip correcto"):
        adopcion_contract.dar_baja(NUMEROCHIP2,{'from':accounts[1]})
    
    with brownie.reverts("Dueno"):
        adopcion_contract.cambio_domicilio("Paseo_Husares,14",NUMEROCHIP2,{'from':accounts[6]})
     
    with brownie.reverts("Microchip correcto"):
        adopcion_contract.cambio_domicilio("Paseo_Husares,14",NUMEROCHIP2,{'from':accounts[4]})
     
    with brownie.reverts("Dueno"):
        adopcion_contract.cambio_telefono("925486253",NUMEROCHIP2,{'from':accounts[6]})
     
    with brownie.reverts("Microchip correcto"):
        adopcion_contract.cambio_telefono("925486253",NUMEROCHIP2,{'from':accounts[4]})
     
    with brownie.reverts("Dueno o protectora"):
        adopcion_contract.cambio_veterinario(accounts[3],NUMEROCHIP2,{'from':accounts[1]})
    
    with brownie.reverts("Microchip correcto"):
        adopcion_contract.cambio_veterinario(accounts[3],NUMEROCHIP2,{'from':accounts[4]})
    
    with brownie.reverts("Protectora"):
        adopcion_contract.consultar_datos({'from':accounts[4]})
    
    time.sleep(6)
    
    with brownie.reverts("Dentro de tiempo"):
        adopcion_contract.vacunar(False,False,NUMEROCHIP,{'from':accounts[1]})
    
    with brownie.reverts("Microchip correcto"):
        adopcion_contract.revision(False, NUMEROCHIP2,{'from':accounts[0]})
