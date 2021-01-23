# @version ^0.2.8

#Contrato de adopcion
struct Datos:
    nombre:String[20]
    apellidos:String[40]
    direccion:String[20]
    telefono:String[9]
    
tiempo_revision: public(uint256)
protectora : public(address)
microchip : public(String[15])
veterinario : public(address)
tasas: public(uint256)

dueno: public(address)
adoptado: public(bool)
tope: uint256
datos: public(Datos)
vacunado:bool

@external
def __init__(_revision: uint256, _numerochip: String[15], _veterinario: address, _tasas : uint256):
    self.protectora = msg.sender
    self.tiempo_revision = _revision
    self.microchip = _numerochip
    self.veterinario = _veterinario
    self.tasas = _tasas
   
@payable
@external
def adoptar(_direccion: String[20],_telefono: String[9],_nombre: String[20],_apellidos:String [40]):
    assert not self.adoptado,"No adoptado"
    assert msg.value == self.tasas,"Tasas exactas"
    self.dueno = msg.sender
    self.adoptado = True
    self.tope = block.timestamp + self.tiempo_revision
    self.datos = Datos({nombre: _nombre, apellidos: _apellidos,direccion: _direccion,telefono: _telefono})
    send(self.protectora,self.tasas)
    self.vacunado = True
    
@external
def vacunar(maltrato: bool, operaciones: bool,_chip:String[15]):
    assert self.adoptado,"Adoptado"
    assert msg.sender == self.veterinario,"Veterinario"
    assert block.timestamp < self.tope,"Dentro de tiempo"
    assert self.microchip == _chip,"Microchip correcto"
    self.vacunado = True
    if maltrato or operaciones:
        self.adoptado = False
        self.dueno = self.protectora
        self.datos = empty(Datos)
    
@external
def revision(apto: bool,_chip:String[15]):
    assert self.adoptado,"Adoptado"
    assert msg.sender == self.protectora,"Protectora"
    assert block.timestamp > self.tope,"Superior al tope"
    assert self.microchip == _chip,"Microchip correcto"
    if apto or not self.vacunado:
        self.adoptado = False
        self.dueno = self.protectora
        self.datos = empty(Datos)
    else:
        self.vacunado = False
        self.tope = block.timestamp + self.tiempo_revision
        
@external
def ceder(_chip:String[15]):
    assert self.adoptado,"Adoptado"
    assert self.microchip == _chip,"Microchip correcto"
    assert msg.sender == self.dueno,"Dueno"
    self.adoptado = False
    self.dueno = self.protectora
    self.datos = empty(Datos)
    
@external
def dar_baja(_chip:String[15]):
    assert msg.sender == self.veterinario,"Veterinario"
    assert self.microchip == _chip,"Microchip correcto"
    selfdestruct(self.protectora)

@external
def cambio_domicilio(_domicilio: String[20],_chip:String[15]):
    assert self.adoptado,"Adoptado"
    assert msg.sender == self.dueno,"Dueno"
    assert self.microchip == _chip,"Microchip correcto"
    self.datos.direccion = _domicilio
    
@external
def cambio_telefono(_telefono: String[9],_chip:String[15]):
    assert self.adoptado,"Adoptado"
    assert msg.sender == self.dueno,"Dueno"
    assert self.microchip == _chip,"Microchip correcto"
    self.datos.telefono = _telefono
    
@external
def cambio_veterinario(_veterinario: address,_chip:String[15]):
    assert msg.sender == self.dueno or msg.sender == self.protectora,"Dueno o protectora"
    assert self.microchip == _chip,"Microchip correcto"
    self.veterinario = _veterinario

@view
@external
def consultar_datos()-> Datos:
    assert msg.sender == self.protectora,"Protectora"
    return self.datos

@view
@external
def consultar_adoptado()->bool:
    return self.adoptado
