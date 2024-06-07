CREATE DATABASE ProyectoCMV;
USE ProyectoCMV;

CREATE TABLE Personal(
	nombre VARCHAR(50) NOT NULL,
    nacionalidad VARCHAR(20) NOT NULL,
    cantidad_peliculas INT NOT NULL,
    CONSTRAINT PK_nombre_p PRIMARY KEY (nombre),
    CONSTRAINT CK_cantidad_pelicula_p CHECK (cantidad_peliculas >= 0)
);

CREATE TABLE Director(
	nombre_director VARCHAR(50),
    CONSTRAINT PK_nombre_director FOREIGN KEY (nombre_director) REFERENCES Personal(nombre) ON DELETE SET NULL
);

CREATE TABLE Protagonista(
	nombre_protagonista VARCHAR(50),
    CONSTRAINT PK_nombre_p FOREIGN KEY (nombre_protagonista) REFERENCES Personal(nombre) ON DELETE SET NULL
);

CREATE TABLE Reparto(
	nombre_reparto VARCHAR(50),
    CONSTRAINT PK_nombre_r FOREIGN KEY (nombre_reparto) REFERENCES Personal(nombre) ON DELETE SET NULL
);

CREATE TABLE Pelicula(
	id_pelicula INT NOT NULL,
    titulo_distribucion VARCHAR(50) NOT NULL,
    titulo_original VARCHAR(50) NOT NULL,
    titulo_español VARCHAR(50) NOT NULL,
    genero VARCHAR(20) NOT NULL,
    idioma_original VARCHAR(20) NOT NULL,
    año_produccion INT NOT NULL,
    resumen VARCHAR(1000) NOT NULL,
    fecha_estreno DATE NOT NULL,
    duracion TIME NOT NULL,
    url VARCHAR(100) NOT NULL,
    calificacion VARCHAR(20) NOT NULL DEFAULT 'Apta todo público',
    nombre_d VARCHAR(50) NOT NULL,
    CONSTRAINT PK_identificador PRIMARY KEY (id_pelicula),
    CONSTRAINT UK_fecha_estreno UNIQUE KEY (fecha_estreno),
    CONSTRAINT CK_identificador CHECK (id_pelicula >= 0),
    CONSTRAINT CK_año_produccion CHECK (año_produccion >= 0),
    CONSTRAINT FK_nombre_d FOREIGN KEY (nombre_d) REFERENCES Director(nombre_director),
    CONSTRAINT CK_calificación CHECK (calificacion IN ('+ 13 años', '+ 15 años','+ 18 años'))
);

DELIMITER $$

CREATE TRIGGER after_insert_pelicula
BEFORE INSERT ON Pelicula
FOR EACH ROW
BEGIN
	SET NEW.titulo_original = UPPER(NEW.titulo_original);
END $$

DELIMITER ;

CREATE TABLE MPelicula(
	id_pelicula INT,
    paises_origen VARCHAR(20),
    CONSTRAINT FK_id_pel FOREIGN KEY (id_pelicula) REFERENCES Pelicula(id_pelicula) ON DELETE CASCADE
);

CREATE TABLE Actuo(
	ident_pelicula INT,
    nombre_p VARCHAR(50),
    CONSTRAINT FK_identificador_p_p FOREIGN KEY (ident_pelicula) REFERENCES Pelicula(id_pelicula) ON DELETE CASCADE,
    CONSTRAINT FK_nombre_p FOREIGN KEY (nombre_p) REFERENCES Protagonista(nombre_protagonista)
);

CREATE TABLE Participo(
	ident_pelicula INT NOT NULL,
    nombre_r VARCHAR(50) NOT NULL,
    CONSTRAINT FK_identificador_p_r FOREIGN KEY (ident_pelicula) REFERENCES Pelicula(id_pelicula) ON DELETE CASCADE,
    CONSTRAINT FK_nombre_r FOREIGN KEY (nombre_r) REFERENCES Reparto(nombre_reparto)
);
    
CREATE TABLE Cine(
	nombre VARCHAR(50) NOT NULL,
    direccion VARCHAR(50) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
	CONSTRAINT PK_nombre_cine PRIMARY KEY (nombre)
);

CREATE TABLE Sala(
	numero INT NOT NULL,
    cantidad_butacas INT NOT NULL,
    nombre_cine VARCHAR(50) NOT NULL,
    CONSTRAINT PK_numero PRIMARY KEY (numero),
    CONSTRAINT CK_numero CHECK (numero >= 0),
    CONSTRAINT FK_nombre_cine_s FOREIGN KEY (nombre_cine) REFERENCES Cine(nombre) ON DELETE CASCADE
);

CREATE TABLE Funcion(
	codigo INT NOT NULL,
    fecha DATE NOT NULL,
    hora_comienzo TIME NOT NULL,
    numero_sala INT,
    id_peli INT,
    CONSTRAINT PK_codigo PRIMARY KEY (codigo),
    CONSTRAINT CK_codigo CHECK (codigo >= 0),
    CONSTRAINT FK_numero FOREIGN KEY (numero_sala) REFERENCES Sala(numero),
    CONSTRAINT FK_id_peli FOREIGN KEY (id_peli) REFERENCES Pelicula(id_pelicula)
);

CREATE TABLE Auditoria (
	id_peli INT,
    titulo_distribucion VARCHAR(50),
    fecha_estreno_anterior DATE,
    fecha_estreno_nueva DATE,
    fecha_modificacion DATETIME,
    CONSTRAINT FK_id_p FOREIGN KEY (id_peli) REFERENCES Pelicula(id_pelicula)
);

DELIMITER $$

CREATE TRIGGER after_update_fecha
AFTER UPDATE ON Pelicula
FOR EACH ROW
BEGIN
	IF (NEW.fecha_estreno <> OLD.fecha_estreno) THEN
		INSERT INTO Auditoria(id_peli, titulo_distribucion, fecha_estreno_anterior, fecha_estreno_nueva, fecha_modificacion)
        VALUES (NEW.id_pelicula, NEW.titulo_distribucion, OLD.fecha_estreno, NEW.fecha_estreno, now());
	END IF;
END $$

DELIMITER ;

INSERT INTO Personal (nombre, nacionalidad, cantidad_peliculas) VALUES
('Justin Lin', 'Taieanés', 6),
('James Wan', 'Malayo', 1),
('Vin Diesel', 'Estadounidense', 5),
('Paul Walker', 'Estadounidense', 6),
('Tyrese Gibson', 'Estadounidense', 5),
('Jordana Brewster', 'Panameño', 5),
('Chad Lindberg', 'Estadounidense', 1),
('Johnny Strong', 'Estadounidense', 4),
('Reggie Lee', 'Filipino', 1),
('Jon Favreau', 'Estadounidense', 1),
('Natalie Portman', 'Jerosolimitano', 1),
('Angelina Jolie', 'Estadounidense', 1);

INSERT INTO Director (nombre_director) VALUES
('Justin Lin'),
('James Wan'),
('Jon Favreau'),
('Natalie Portman'),
('Angelina Jolie');

INSERT INTO Protagonista (nombre_protagonista) VALUES
('Vin Diesel'),
('Paul Walker'),
('Tyrese Gibson'),
('Jordana Brewster'),
('Natalie Portman');

INSERT INTO Reparto (nombre_reparto) VALUES
('Chad Lindberg'),
('Johnny Strong'),
('Reggie Lee'),
('Jon Favreau');

INSERT INTO Pelicula (id_pelicula, titulo_distribucion, titulo_original, titulo_español, genero, idioma_original, año_produccion, resumen, fecha_estreno, duracion, url, calificacion, nombre_d) VALUES
(1, 'The Fast and The Furious', 'the fast AND THE FURIOUS', 'Rápido y Furioso', 'Acción', 'Inglés', 2001, 'Un policía encubierto se infiltra en una subcultura del inframundo de corredores callejeros de Los Ángeles que buscan reventar una red de secuestros, y pronto comienza a cuestionar sus lealtades.', '2001-06-22', '01:47:00', 'http://www.rapidosyfuriosos.com.ar/franchise.php?id=4', '+ 13 años', 'Justin Lin'),
(2, '2 Fast 2 Furious', '2 fast 2 furious', 'Más Rápidos Más Furiosos', 'Acción', 'Inglés', 2003, 'Cuando el ex policía, Brian O`Conner, es capturado en Miami por su antiguo socio, Bilkins, lo reclutan para acabar con un narcotraficante llamado Carter Verone. O`Connor acepta ayudarlos en los términos de crear su propio equipo. Decide formar equipo con su amigo de la infancia, Roman Pearce.', '2003-06-06', '01:47:00', 'http://www.rapidosyfuriosos.com.ar/franchise.php?id=4', '+ 13 años', 'Justin Lin'),
(3, 'The Fast and the Furious: Tokyo Drift', 'tHe fast aNd the furious: TOKYO DRIFT', 'Rápido y furioso: Reto Tokio', 'Acción', 'Inglés', 2006, 'Sean es un chico que no se adapta a ningún grupo, su única conexión con el mundo son las carreras ilegales, lo que lo ha convertido en el perseguido número uno por la policía. Cuando lo amenazan de cárcel, lo mandan a Japón con su padre. Estando en este país es atraído por el último reto automovilístico que desafía la gravedad: las carreras drift, una mezcla peligrosa de alta velocidad en pistas con curvas muy cerradas y en zigzag. Estas carreras lo llevan a involucrase con la mafia japonesa, el hampa de Tokio y a jugarse la vida.', '2006-06-16', '01:44:00', 'http://www.rapidosyfuriosos.com.ar/franchise.php?id=4', '+ 13 años', 'Justin Lin'),
(4, 'Fast & Furious', 'fast & furious', 'Rápidos y Furiosos', 'Acción', 'Inglés', '2009', 'Un asesinato obliga a Don Toretto, un ex convicto huido, y al agente Brian O`Conner a volver a Los Ángeles. donde su pelea se reaviva. Pero al tener que enfrentarse a un enemigo común, se ven obligados a formar una alianza incierta si quieren conseguir desbaratar sus planes.', '2009-04-03', '01:47:00', 'http://www.rapidosyfuriosos.com.ar/franchise.php?id=4', '+ 13 años', 'Justin Lin'),
(5, 'Fast Five', 'fast five', 'Rápidos y Furiosos 5in Control', 'Acción', 'Inglés', 2011, 'Luke Hobbs, un duro agente federal acostumbrado a dar caza a todos sus objetivos, debe confiar en su instinto para atraparles y que nadie más se le adelante. De esta forma, él y su equipo se embarcarán en un veloz viaje sin tregua para frenar a los protagonistas de la saga.', '2011-04-29', '02:11:00', 'https://www.imdb.com/title/tt1596343/', '+ 15 años', 'Justin Lin'),
(6, 'Fast & Furious 6', 'fasT & FurIouS 6', 'Rápido y Furioso 6', 'Acción', 'Inglés', 2013, 'Desde que Dom y Brian destruyeron el imperio de un mafioso y se hicieron con cien millones de dólares, se encuentran en paradero desconocido; no pueden regresar a casa porque la ley los persigue. Entretanto, Hobbs ha seguido la pista por una docena de países a una banda de letales conductores mercenarios, cuyo cerebro cuenta con la inestimable ayuda de la sexy Letty, un viejo amor de Dom que éste daba por muerta. La única forma de detenerlos es enfrentarse a ellos en las calles, así que Hobbs le pide a Dom que reúna a su equipo en Londres. ¿Qué obtendrán a cambio? Un indulto para que todos puedan volver a casa con sus familias.', '2013-05-24', '02:10:00', 'https://www.imdb.com/title/tt1905041/', '+ 15 años', 'Justin Lin'),
(7, 'Furious 7', 'furious 7', 'Rápidos y Furiosos 7', 'Acción', 'Inglés', 2015, 'Luego de haber derrotado al terrorista Owen Shaw, Dominic Toretto y sus amigos creían haber dejado la vida ruda atrás. Sin embargo, Deckard Shaw, el hermano de Owen, aparece de pronto para cobrar venganza. Su intención es eliminar al clan que exterminó a su hermano, uno por uno. ', '2015-04-03', '02:20:00', 'https://www.imdb.com/title/tt2820852/', '+ 15 años', 'James Wan'),
(8, 'Iron Man', 'IRON MAN', 'El hombre de hierro', 'Acción', 'Inglés', 2008, 'Tony Stark es un inventor de armamento brillante que es secuestrado en el extranjero. Sus captores son unos terroristas que le obligan a construir una máquina destructiva pero Tony se construirá una armadura para poder enfrentarse a ellos y escapar.', '2008-04-30', '02:06:00', 'https://www.marvel.com/', '+ 15 años', 'Jon Favreau'),
(9, 'A Tale of Love and Darkness', 'A Tale of Love and Darkness', 'Un historia de amor y oscuridad', 'Belico/Romance', 'Inglés', 2015, 'Basada en las memorias de Amos Oz, uno de los primeros escritores judíos que abogó por encontrar una solución al eterno conflicto entre Israel y Palestina. Desde su propio punto de vista, en aquel momento era tan sólo un niño, el autor aborda la creación del Estado de Israel. A los doce años, su madre se suicida y su vida queda marcada para siempre por este hecho. Tras esta tragedia, comienza a trabajar como escritor, participando activamente en la vida política del país.', '2015-09-14', '01:35:00', 'NULL', '+ 13 años', 'Natalie Portman'),
(10, 'In The Land of Blood and Honey', 'In The Land of Blood and Honey', 'En tierra de sangre y miel', 'Belico/Romance', 'Inglés', 2011, 'Antes de la guerra de los Balcanes (años 90), Danijel, un policía serbio, y Ajla, una joven artista bosnia de religión musulmana, se conocieron y se enamoraron, pero la guerra y la terrible violencia que asoló el país los cambió para siempre. Al verse involucrados en el conflicto, su relación y la lealtad que se profesaban empezaron a desmoronarse.', '2011-12-23', '02:07:00', 'NULL', '+ 13 años', 'Angelina Jolie');

INSERT INTO MPelicula (id_pelicula, paises_origen) VALUES
(1, 'Estados Unidos'),
(2, 'Estados Unidos'),
(3, 'Estados Unidos'),
(4, 'Estados Unidos'),
(5, 'Estados Unidos'),
(6, 'Estados Unidos'),
(7, 'Estados Unidos'),
(8, 'Estados Unidos'),
(9, 'Estados Unidos'),
(10, 'Estados Unidos');

INSERT INTO Actuo (ident_pelicula, nombre_p) VALUES
(1,'Vin Diesel'),
(4,'Vin Diesel'),
(5,'Vin Diesel'),
(6,'Vin Diesel'),
(7,'Vin Diesel'),
(1, 'Paul Walker'),
(2, 'Paul Walker'),
(4, 'Paul Walker'),
(5, 'Paul Walker'),
(6, 'Paul Walker'),
(7, 'Paul Walker'),
(2, 'Tyrese Gibson'),
(4, 'Tyrese Gibson'),
(5, 'Tyrese Gibson'),
(6, 'Tyrese Gibson'),
(7, 'Tyrese Gibson'),
(1, 'Jordana Brewster'),
(4, 'Jordana Brewster'),
(5, 'Jordana Brewster'),
(6, 'Jordana Brewster'),
(7, 'Jordana Brewster'),
(9, 'Natalie Portman');

INSERT INTO Participo (ident_pelicula, nombre_r) VALUES
(1, 'Chad Lindberg'),
(1, 'Johnny Strong'),
(5, 'Johnny Strong'),
(6, 'Johnny Strong'),
(7, 'Johnny Strong'),
(1, 'Reggie Lee'),
(8, 'Jon Favreau');

INSERT INTO Cine (nombre, direccion, telefono) VALUES
('Cine del Paseo', 'Sobremonte 80, Río Cuarto, Córdoba', '03584621235'),
('Cine Hoyts Patio Olmos', 'Vélez Sarsfield 361, Córdoba', '03514238408');

INSERT INTO Sala (numero, cantidad_butacas, nombre_cine) VALUES
(1, 50, 'Cine del Paseo'),
(2, 75, 'Cine del Paseo'),
(3, 60, 'Cine del Paseo'),
(4, 45, 'Cine del Paseo'),
(5, 100, 'Cine Hoyts Patio Olmos'),
(6, 110, 'Cine Hoyts Patio Olmos'),
(7, 80, 'Cine Hoyts Patio Olmos');

INSERT INTO Funcion (codigo, fecha, hora_comienzo, numero_sala, id_peli) VALUES
(1, '2024-05-12', '22:30:00', 1, 1),
(2, '2024-05-12', '23:00:00', 2, 2),
(3, '2024-05-13', '20:30:00', 1, 1),
(4, '2024-05-12', '18:30:00', 3, 3),
(5, '2024-05-14', '18:00:00', 3, 3),
(6, '2024-05-10', '14:00:00', 5, 4),
(7, '2024-05-15', '15:30:00', 6, 5);