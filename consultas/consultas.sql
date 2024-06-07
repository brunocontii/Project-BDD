USE ProyectoCMV;

-- Actores que solo estuvieron en una pelicula
SELECT nombre_protagonista FROM Protagonista JOIN Actuo ON Protagonista.nombre_protagonista = Actuo.nombre_p GROUP BY nombre_protagonista HAVING COUNT(Actuo.ident_pelicula) = 1;
            
-- Personas que actuaron y dirigieron
SELECT DISTINCT nombre_director FROM Director JOIN Protagonista ON Director.nombre_director = Protagonista.nombre_protagonista UNION SELECT DISTINCT nombre_director FROM Director JOIN Reparto ON Director.nombre_director = Reparto.nombre_reparto;

-- Cines con butacas totales
SELECT Cine.nombre, SUM(Sala.cantidad_butacas) AS total_butacas FROM Cine JOIN Sala ON Cine.nombre = Sala.nombre_cine GROUP BY Cine.nombre;

-- Peliculas que duran más de 1 hora y 45 minutos
SELECT titulo_español, duracion FROM Pelicula WHERE duracion > '01:45:00';

-- Peliculas entre 2010 y 2015
SELECT titulo_español, año_produccion FROM Pelicula WHERE año_produccion BETWEEN 2010 AND 2015;

-- Mostrar el titulo y la fecha de estreno de las peliculas que se proyectaron en el Cine del Paseo
SELECT titulo_distribucion, fecha_estreno FROM Pelicula WHERE id_pelicula IN (SELECT id_peli FROM Funcion WHERE numero_sala IN (SELECT numero FROM Sala WHERE nombre_cine = 'Cine del Paseo'));

