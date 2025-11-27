-- Crea la base de datos si no existe
CREATE DATABASE IF NOT EXISTS sistecread;
USE sistecread;

-- Tabla de libros (completa con stock)
CREATE TABLE IF NOT EXISTS libros (
  id INT AUTO_INCREMENT PRIMARY KEY,
  titulo VARCHAR(255) NOT NULL,
  autor VARCHAR(255) NOT NULL,
  imagen VARCHAR(500),
  descripcion TEXT,
  publicado DATE,
  editorial VARCHAR(100),
  encuadernacion VARCHAR(50),
  precio DECIMAL(10,2) NOT NULL,
  categoria VARCHAR(100) NOT NULL DEFAULT 'general',
  stock INT(11) DEFAULT 100,
  creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de usuarios (completa con campos de reset password)
CREATE TABLE IF NOT EXISTS usuarios (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  rol ENUM('user', 'admin') DEFAULT 'user',
  creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  reset_token VARCHAR(255) DEFAULT NULL,
  reset_expires DATETIME DEFAULT NULL
);

-- Tabla de mensajes de contacto
CREATE TABLE IF NOT EXISTS contactos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL,
  asunto VARCHAR(100) NOT NULL,
  mensaje TEXT NOT NULL,
  enviado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de ventas (completa con información de envío)
CREATE TABLE IF NOT EXISTS ventas (
  id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT,
  total DECIMAL(10,2) NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL,
  telefono VARCHAR(15) NOT NULL,
  cp VARCHAR(5) NOT NULL,
  tipo_entrega ENUM('domicilio', 'retiro') NOT NULL,
  direccion TEXT,
  descripcion_casa TEXT,
  ciudad VARCHAR(100),
  estado ENUM('pendiente', 'pagado', 'enviado', 'completado') DEFAULT 'pendiente',
  metodo_pago VARCHAR(20),
  creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE SET NULL
);

-- Tabla de detalles de ventas
CREATE TABLE IF NOT EXISTS venta_detalles (
  id INT AUTO_INCREMENT PRIMARY KEY,
  venta_id INT,
  libro_id INT,
  cantidad INT NOT NULL,
  precio DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (venta_id) REFERENCES ventas(id) ON DELETE CASCADE,
  FOREIGN KEY (libro_id) REFERENCES libros(id) ON DELETE SET NULL
);

-- Inserta admin de ejemplo (password: admin123)
INSERT INTO usuarios (nombre, email, password, rol) VALUES (
  'Admin',
  'admin@sistecread.com',
  '$2y$10$o6dK6wG2g2wZ0fC0z3y1meY1wZ0fC0z3y1meY1wZ0fC0z3y1me',
  'admin'
);

-- Tus INSERTs de libros aquí (se mantienen igual)...

-- Inserta todos los libros
INSERT INTO libros (titulo, autor, imagen, descripcion, publicado, editorial, encuadernacion, precio, categoria) VALUES
-- Más Vendidos
('Sus ojos miraban a Dios', 'Zora Neale Hurston', 'https://shop.mtwyouth.org/cdn/shop/files/61_KbxrnHxL.jpg?v=1736152142&width=990', 'Una de las obras más importantes de la literatura estadounidense del siglo XX, el amado clásico de 1937 de Zora Neale Hurston, Their Eyes Were Watching God, es una historia de amor sureña perdurable que brilla con ingenio, belleza y sabiduría sincera.', '2006-01-03', 'Harper Perennial', 'Rústica', 17.99, 'mas-vendidos'),
('Olive, Again: Una novela', 'Elizabeth Strout', 'https://shop.mtwyouth.org/cdn/shop/files/51SOYJGewiL_61e1065d-0464-49d0-bdf0-dfa5138de3b2.jpg?v=1736151644&width=990', 'Espinosa, irónica, resistente al cambio pero despiadadamente honesta y profundamente empática, Olive Kitteridge es "una fuerza vital convincente" (San Francisco Chronicle).', '2020-11-03', 'Random House Trade Paperbacks', 'Rústica', 18.00, 'mas-vendidos'),
('La bailarina del agua: una novela', 'Ta-Nehisi Coates', 'https://shop.mtwyouth.org/cdn/shop/files/51gSloBtq0L.jpg?v=1736148004&width=990', 'Este potente libro sobre el pecado más vergonzoso de Estados Unidos establece [a Ta-Nehisi Coates] como un novelista de primer orden.', '2020-11-17', 'One World', 'Rústica', 19.00, 'mas-vendidos'),
('Nimona', 'Noelle Stevenson', 'https://shop.mtwyouth.org/cdn/shop/files/51boHj8x7vL_fc22898b-f15b-454c-90cd-628053e43afb.jpg?v=1736145118&width=990', 'Nimona es una joven cambiaformas impulsiva con una habilidad especial para la villanía. Lord Ballister Blackheart es un villano con una venganza.', '2015-05-12', 'Quill Tree Books', 'Rústica', 18.99, 'mas-vendidos'),
('El diario de una niña', 'Ana Frank', 'https://shop.mtwyouth.org/cdn/shop/files/51DvoRaqkvL.jpg?v=1741801884&width=990', 'El diario de una niña de Ana Frank se encuentra entre los documentos más perdurables del siglo XX. Sigue siendo un testimonio amado y profundamente admirado de la naturaleza indestructible del espíritu humano.', '1997-02-03', 'Bantam', 'Libro de bolsillo', 8.99, 'mas-vendidos'),

-- Literatura Contemporánea
('¡Yo!', 'Julia Alvarez', 'https://tse1.mm.bing.net/th/id/OIP.RrGvlYUT4Ur97-m8XTk1vAHaLJ?rs=1&pid=ImgDetMain&o=7&rm=3', 'La odisea estadounidense de Yo, una escritora dominicana cuya familia llegó a los Estados Unidos como refugiados de una dictadura. La novela sigue su juventud, con su energía y optimismo, y los contratiempos a medida que envejece, incluidos dos divorcios.', '1997-12-01', NULL, 'Rústica', 6.95, 'literatura-contemporanea'),
('Olive, Again: Una novela', 'Elizabeth Strout', 'https://shop.mtwyouth.org/cdn/shop/files/51SOYJGewiL_61e1065d-0464-49d0-bdf0-dfa5138de3b2.jpg?v=1736151644&width=990', 'Espinosa, irónica, resistente al cambio pero despiadadamente honesta y profundamente empática, Olive Kitteridge es "una fuerza vital convincente" (San Francisco Chronicle). Olive lucha por comprenderse no solo a sí misma y a su propia vida, sino también a las vidas de quienes la rodean en la ciudad de Crosby, Maine.', '2020-11-03', 'Random House Trade Paperbacks', 'Rústica', 18.00, 'literatura-contemporanea'),
('Sus ojos miraban a Dios', 'Zora Neale Hurston', 'https://shop.mtwyouth.org/cdn/shop/files/61_KbxrnHxL.jpg?v=1736152142&width=990', 'Una de las obras más importantes de la literatura estadounidense del siglo XX, el amado clásico de 1937 de Zora Neale Hurston, Their Eyes Were Watching God, es una historia de amor sureña perdurable que brilla con ingenio, belleza y sabiduría sincera.', '2006-01-03', 'Harper Perennial', 'Rústica', 17.99, 'literatura-contemporanea'),
('Sus ojos miraban a Dios (Edición Tapa Dura)', 'Zora Neale Hurston', 'https://shop.mtwyouth.org/cdn/shop/files/61OCtY5hROL.jpg?v=1739382917&width=990', 'Una novela profundamente conmovedora que comprende el amor y la crueldad, y separa a las personas grandes de los pequeños de corazón, sin perder nunca la simpatía por aquellos desafortunados que no saben cómo vivir adecuadamente.', '2021-01-05', 'Amistad Press', 'Tapa dura', 27.99, 'literatura-contemporanea'),

-- Literatura Histórica
('Viaje a casa', 'Yoshiko Uchida', 'https://shop.mtwyouth.org/cdn/shop/files/51udpdbi6mL.jpg?v=1745604319&width=990', 'Después de su liberación de un campo de concentración estadounidense, una niña japonesa-estadounidense y su familia intentan reconstruir sus vidas en medio de fuertes sentimientos antijaponeses que generan miedo, desconfianza y violencia.', '1992-10-31', 'Aladdin', 'Rústica', 6.95, 'literatura-historica'),
('La pulsera', 'Yoshiko Uchida', 'https://shop.mtwyouth.org/cdn/shop/files/61dIeezfklL.jpg?v=1747331162&width=990', 'Yoshiko Uchida se basa en su propia infancia como japonesa-estadounidense durante la Segunda Guerra Mundial en un campo de internamiento para contar la conmovedora historia del descubrimiento del poder de la memoria por parte de una niña.', '1996-11-12', 'Puffin Books', 'Rústica', 6.95, 'literatura-historica'),
('Corazón de un samurái', 'Margi Preus', 'https://shop.mtwyouth.org/cdn/shop/files/51p8_eYSKNL.jpg?v=1758852689&width=990', 'En 1841 se hunde un barco pesquero japonés. Su tripulación se ve obligada a nadar hasta una isla pequeña y desconocida, donde son rescatados por un barco estadounidense. Manjiro, un niño de 14 años, es curioso y está ansioso por aprender todo lo que pueda sobre esta nueva cultura.', '2012-02-01', 'Harry N. Abrams', 'Rústica', 6.95, 'literatura-historica'),
('En el tiempo de las mariposas', 'Julia Alvarez', 'https://shop.mtwyouth.org/cdn/shop/files/4151OPXYASL.jpg?v=1736152383&width=990', 'Es el 25 de noviembre de 1960 y tres hermosas hermanas han sido encontradas cerca de su Jeep destrozado. Las hermanas estuvieran entre los principales opositores a la dictadura del general Rafael Leonidas Trujillo. Todo el mundo conoce Las Mariposas, "Las mariposas".', NULL, 'Algonquin Books', NULL, 18.99, 'literatura-historica'),
('El diario de una niña', 'Ana Frank', 'https://shop.mtwyouth.org/cdn/shop/files/51DvoRaqkvL.jpg?v=1741801884&width=990', 'El diario de una niña de Ana Frank se encuentra entre los documentos más perdurables del siglo XX. Desde su publicación en 1947, ha sido leído por decenas de millones de personas en todo el mundo. Sigue siendo un testimonio amado y profundamente admirado de la naturaleza indestructible del espíritu humano.', '1997-02-03', 'Bantam', 'Libro de bolsillo para el mercado masivo', 8.99, 'literatura-historica'),

-- Ficción Afroamericana
('La bailarina del agua: una novela', 'Ta-Nehisi Coates', 'https://shop.mtwyouth.org/cdn/shop/files/51gSloBtq0L.jpg?v=1736148004&width=990', 'Este potente libro sobre el pecado más vergonzoso de Estados Unidos establece [a Ta-Nehisi Coates] como un novelista de primer nivel.', '2020-11-17', 'One World', 'Rústica', 19.00, 'ficcion-afroamericana'),
('Los chicos del níquel: una novela', 'Colson Whitehead', 'https://shop.mtwyouth.org/cdn/shop/files/41f9FbE7RYL.jpg?v=1736172990&width=990', 'Basada en la historia real de un reformatorio que funcionó durante 111 años y deformó la vida de miles de niños, The Nickel Boys es una narrativa devastadora e impulsada que muestra a un gran novelista estadounidense escribiendo en el apogeo de sus poderes.', '2019-07-16', 'Doubleday', 'Tapa dura', 27.00, 'ficcion-afroamericana'),
('Ve a contarlo en la montaña', 'James Baldwin', 'https://shop.mtwyouth.org/cdn/shop/files/51xa_SWoPkL.jpg?v=1736151083&width=990', 'El doble resultado de More Than Words: cada compra brinda oportunidades prácticas de capacitación laboral y todos los ingresos apoyan a nuestra organización sin fines de lucro para capacitar a los jóvenes para que se hagan cargo de sus vidas.', '2013-09-12', 'Vintage', 'Rústica', 16.00, 'ficcion-afroamericana'),

-- Novelas Gráficas
('Nimona', 'Noelle Stevenson', 'https://shop.mtwyouth.org/cdn/shop/files/51boHj8x7vL_fc22898b-f15b-454c-90cd-628053e43afb.jpg?v=1736145118&width=990', 'Nimona es una joven cambiaformas impulsiva con una habilidad especial para la villanía. Lord Ballister Blackheart es un villano con una venganza. Como compañera y supervillana, Nimona y Lord Blackheart están a punto de causar estragos.', '2015-05-12', 'Quill Tree Books', 'Rústica', 18.99, 'novelas-graficas'),
('Ley de clase', 'Jerry Craft', 'https://shop.mtwyouth.org/cdn/shop/files/51MhBD8WuYL.jpg?v=1736149263&width=990', 'Drew Ellis, estudiante de octavo grado, no es ajeno al dicho "Tienes que trabajar el doble para ser igual de bueno". Su abuela se lo ha recordado toda su vida. Pero, ¿qué pasa si trabaja diez veces más duro y aún no tiene las mismas oportunidades que sus privilegiados compañeros de clase?', '2020-10-06', 'Quill Tree Books', 'Rústica', 15.99, 'novelas-graficas'),
('Cabezas de calabaza', 'Rainbow Rowell', 'https://shop.mtwyouth.org/cdn/shop/files/519OHqOUISL.jpg?v=1750355120&width=990', 'Josiah está listo para pasar toda la noche sintiéndose melancólico por eso. Deja no está listo para dejarlo. Ella tiene un plan: ¿Qué pasaría si, en lugar de deprimirse y arrojar frijoles de lima en la cabaña de Succotash, salieran con una explosión?', '2019-08-27', 'First Second', 'Rústica', 18.99, 'novelas-graficas'),

-- Ficción Internacional
('Antes de que el café se enfríe: una novela', 'Toshikazu Kawaguchi', 'https://shop.mtwyouth.org/cdn/shop/files/4174AJ-RtVL.jpg?v=1747058448&width=990', 'En un pequeño callejón de Tokio, hay una cafetería que ha estado sirviendo café cuidadosamente preparado durante más de cien años. La leyenda local dice que esta tienda ofrece algo más que café: la oportunidad de viajar en el tiempo.', '2020-11-17', 'Hanover Square Press', 'Tapa dura', 19.99, 'ficcion-internacional'),
('Crimen y castigo', 'Fiódor Dostoievski', 'https://shop.mtwyouth.org/cdn/shop/files/51X8dkqlDdL.jpg?v=1754762058&width=990', 'Durante más de sesenta y cinco años, Penguin ha sido la editorial líder de literatura clásica en el mundo de habla inglesa. Con más de 1.500 títulos, Penguin Classics representa una estantería global de las mejores obras a lo largo de la historia.', '2015-07-14', 'Penguin', NULL, 22.00, 'ficcion-internacional'),

-- Ciencia Ficción
('Semilla silvestre', 'Octavia E. Butler', 'https://shop.mtwyouth.org/cdn/shop/files/51YYB09ZfYL.jpg?v=1740535456&width=990', 'Doro no conoce una autoridad superior a él mismo. Un espíritu antiguo con poderes ilimitados, posee humanos, matando sin remordimiento mientras salta de cuerpo en cuerpo para mantener su propia vida. Con una eternidad solitaria por delante, Doro cría humanos sobrenaturalmente dotados.', '2020-03-17', 'Grand Central Publishing', 'Rústica', 18.99, 'ciencia-ficcion'),
('Érase una vez un corazón roto', 'Stephanie Garber', 'https://shop.mtwyouth.org/cdn/shop/files/41oq-e-5gGL_a6b7c230-097d-442a-bb1b-403edbb9e713.jpg?v=1736159980&width=990', 'El doble resultado de More Than Words: cada compra brinda oportunidades prácticas de capacitación laboral y todos los ingresos apoyan a nuestra organización sin fines de lucro para capacitar a los jóvenes para que se hagan cargo de sus vidas.', '2023-03-28', NULL, 'Rústica', 12.99, 'ciencia-ficcion'),
('El ojo de la novia Bedlam', 'Matt Dinniman', 'https://tse3.mm.bing.net/th/id/OIP.RdinnXWmOPYszqniVak_qgHaL2?rs=1&pid=ImgDetMain&o=7&rm=3', 'El doble resultado de More Than Words: cada compra brinda oportunidades prácticas de capacitación laboral y todos los ingresos apoyan a nuestra organización sin fines de lucro para capacitar a los jóvenes para que se hagan cargo de sus vidas.', '2025-05-13', 'Ace', NULL, 39.00, 'ciencia-ficcion'),
('Bestias y Behemoths', 'Andrew Stacey Wheeler', 'https://shop.mtwyouth.org/cdn/shop/files/51CXoj62-bL_b800d0ac-6639-48ec-970f-aa72ac2c0ae6.jpg?v=1736149331&width=990', 'Esta guía ilustrada transporta a los nuevos jugadores al mundo mágico de Dungeons & Dragons y presenta un curso único en su tipo sobre las criaturas inusuales, desde las minúsculas hasta las masivas, que llenan el mundo fantástico del juego.', '2020-10-20', 'Ten Speed Press', 'Tapa dura', 12.99, 'ciencia-ficcion'),

-- Infantiles y Juveniles
('Cómo atrapar un Yeti', 'Adam Wallace', 'https://shop.mtwyouth.org/cdn/shop/files/51zrujY2oaL.jpg?v=1751492717&width=990', 'Cuando nuestros brillantes niños del Catch Club se enteran del legendario Yeti, se dirigen a las montañas para echar un vistazo y demostrar que realmente existe. Lleno de divertidas travesuras y trampas inteligentes.', '2020-09-01', 'Sourcebooks Wonderland', 'Tapa dura', 10.99, 'infantiles-juveniles'),
('¿Dónde está Waldo ahora?', 'Martin Handford', 'https://tse4.mm.bing.net/th/id/OIP.JdrHftfGVPEmW5GPomTjkgHaJJ?rs=1&pid=ImgDetMain&o=7&rm=3', 'Waldo y sus amigos Wenda, Woof, Wizard Whitebeard y Odlaw están apareciendo en escenas a lo largo de la historia, apareciendo junto a hombres de las cavernas, gladiadores, mineros de oro y más. ¡Waldo incluso se pierde en el futuro!', '2019-12-24', 'Candlewick', 'Rústica', 8.99, 'infantiles-juveniles'),
('Libro de cartón del oso Paddington', 'Michael Bond', 'https://shop.mtwyouth.org/cdn/shop/files/510y2mnH18L.jpg?v=1753753907&width=990', 'Paddington Bear ha encantado a los lectores durante generaciones. Escrito en rima simple para los fanáticos más jóvenes, y combinado con el arte animado de R. W. Alley, este libro de cartón es una gran introducción a Paddington.', '2014-07-22', 'HarperFestival', 'Libro de cartón', 9.99, 'infantiles-juveniles'),
('La granja que nos alimenta', 'Nancy Castaldo', 'https://shop.mtwyouth.org/cdn/shop/files/51axNIZMc_L.jpg?v=1751896402&width=990', 'Explore el funcionamiento de una granja familiar orgánica a pequeña escala y experimente el ritmo de la vida agrícola. En la primavera, visite el gallinero, labre los campos y recorra la maquinaria agrícola.', '2020-07-21', 'Palabras e Imágenes', 'Tapa dura', 19.95, 'infantiles-juveniles'),
('El árbol ocupado', 'Jennifer Ward', 'https://m.media-amazon.com/images/I/A1rWUtKoEnL._SL1500_.jpg', 'Espectaculares ilustraciones realizadas en pintura al óleo y un texto que rima que describe las actividades de un árbol desde sus raíces hasta sus ramas, presentan a los jóvenes lectores las increíbles actividades que se realizan en un árbol.', '2009-09-01', 'Dos Leones', 'Tapa dura', 17.99, 'infantiles-juveniles'),
('Tiempo de limpieza', 'Elizabeth Verdick', 'https://shop.mtwyouth.org/cdn/shop/files/5154rw_KsKL.jpg?v=1751478741&width=990', 'Los niños pequeños esperarán con ansias la hora de limpiar con este sencillo libro de rimas que los anima a cantar mientras ordenan. Los niños pequeños aprenden a trabajar juntos para poner artículos en su lugar.', '2008-08-10', 'Free Spirit Publishing', 'Libro de cartón', 9.99, 'infantiles-juveniles'),
('¡Oh, los pensamientos que puedes pensar!', 'Dr. Seuss', 'https://shop.mtwyouth.org/cdn/shop/files/51fclNUlpDL.jpg?v=1742277136&width=990', 'Originalmente creados por el Dr. Seuss, los libros para principiantes alientan a los niños a leer por sí mismos, con palabras simples e ilustraciones que dan pistas sobre su significado.', '2009-08-11', 'Random House Books for Young Readers', 'Libro de cartón', 5.99, 'infantiles-juveniles'),
('Bella el hada conejita', 'Daisy Meadows', 'https://shop.mtwyouth.org/cdn/shop/files/51bLrd-UAZL.jpg?v=1742248525&width=990', 'El doble resultado de More Than Words: cada compra brinda oportunidades prácticas de capacitación laboral y todos los ingresos apoyan a nuestra organización sin fines de lucro.', '2024-05-14', 'Silver Dolphin Books', NULL, 5.99, 'infantiles-juveniles'),

-- No Ficción
('Potencial oculto', 'Adam Grant', 'https://shop.mtwyouth.org/cdn/shop/files/41yQYmGoutL.jpg?v=1744408410&width=990', 'El doble resultado de More Than Words: cada compra brinda oportunidades prácticas de capacitación laboral y todos los ingresos apoyan a nuestra organización sin fines de lucro para capacitar a los jóvenes para que se hagan cargo de sus vidas.', '2023-10-24', NULL, 'Tapa dura', 32.00, 'no-ficcion'),
('El Proyecto 1619', 'Sin especificar', 'https://images.justwatch.com/poster/306354628/s718/temporada-1.jpg', 'El doble resultado de More Than Words: cada compra brinda oportunidades prácticas de capacitación laboral y todos los ingresos apoyan a nuestra organización sin fines de lucro.', '2021-11-16', NULL, 'Tapa dura', 38.00, 'no-ficcion'),
('Para hacer libres a los hombres', 'Heather Cox Richardson', 'https://shop.mtwyouth.org/cdn/shop/files/41Xc1WWb-tL.jpg?v=1736158279&width=990', 'El doble resultado de More Than Words: cada compra brinda oportunidades prácticas de capacitación laboral y todos los ingresos apoyan a nuestra organización sin fines de lucro.', '2021-11-23', NULL, 'Rústica', 19.99, 'no-ficcion'),
('Los estadounidenses indocumentados', 'Karla Cornejo Villavicencio', 'https://shop.mtwyouth.org/cdn/shop/files/51C12KhLtOL.jpg?v=1741010211&width=990', 'FINALISTA DEL PREMIO NACIONAL DEL LIBRO. Una de las primeras inmigrantes indocumentadas en graduarse de Harvard revela las vidas ocultas de sus compatriotas estadounidenses indocumentados.', '2021-04-06', NULL, 'Rústica', 20.00, 'no-ficcion'),
('Espiando en el sur', 'Tony Horwitz', 'https://shop.mtwyouth.org/cdn/shop/files/51kZEiFHxeL.jpg?v=1744639253&width=990', 'Con Spying on the South, el autor más vendido de Confederates in the Attic regresa al sur y a la época de la Guerra Civil para una aventura épica tras la pista del mejor arquitecto paisajista de Estados Unidos.', '2020-05-12', 'Penguin Books', 'Rústica', 19.00, 'no-ficcion'),
('Más allá de las mentiras de COVID-19', 'Bryan Ardis', 'https://shop.mtwyouth.org/cdn/shop/files/41gNXEfdHaL.jpg?v=1750297883&width=990', 'El doble resultado de More Than Words: cada compra brinda oportunidades prácticas de capacitación laboral y todos los ingresos apoyan a nuestra organización sin fines de lucro.', '2024-10-01', 'Harvest Creek Publishing', NULL, 24.99, 'no-ficcion'),

-- Filosofía y Religión
('Meditaciones de Marco Aurelio', 'Marco Aurelio', 'https://shop.mtwyouth.org/cdn/shop/files/41iLX5vhBgL.jpg?v=1736166207&width=990', 'El doble resultado de More Than Words: cada compra brinda oportunidades prácticas de capacitación laboral y todos los ingresos apoyan a nuestra organización sin fines de lucro.', '2021-06-30', 'PETER PAUPER PRESS', NULL, 7.99, 'filosofia-religion'),
('NKJV, Biblia de alcance', 'Thomas Nelson', 'https://shop.mtwyouth.org/cdn/shop/files/31TyU3zJ9ZL.jpg?v=1736160261&width=990', 'El doble resultado de More Than Words: cada compra brinda oportunidades prácticas de capacitación laboral y todos los ingresos apoyan a nuestra organización sin fines de lucro.', '2017-06-06', 'Thomas Nelson', 'Rústica', 19.99, 'filosofia-religion'),

-- Cine y Artes
('Notas sobre el cinematógrafo', 'Robert Bresson', 'https://shop.mtwyouth.org/cdn/shop/files/51ml1LiKDCL.jpg?v=1749750558&width=990', 'El director de cine francés Robert Bresson fue uno de los grandes artistas del siglo XX y uno de los estilistas más radicales, originales y radiantes de cualquier época. Trabajó con actores no profesionales, modelos, como él los llamaba.', '2016-11-15', 'NYRB Classics', 'Rústica', 15.95, 'cine-artes'),
('Rebelde sin equipo', 'Robert Rodríguez', 'https://shop.mtwyouth.org/cdn/shop/files/512u6IAhfvL.jpg?v=1749664331&width=990', 'Nadie ha aterrizado en el mapa cinematográfico con más fuerza explosiva que Robert Rodríguez, director de "El Mariachi". ¿Cómo se las arregló este cineasta aficionado de Texas para completar un largometraje por $7,000?', '1996-09-01', 'Plume', 'Rústica', 18.00, 'cine-artes'),

-- Misterio y Thriller
('Mata bien con otros', 'Deanna Raybourn', 'https://shop.mtwyouth.org/cdn/shop/files/411S3xdv-tL.jpg?v=1741812754&width=990', 'El doble resultado de More Than Words: cada compra brinda oportunidades prácticas de capacitación laboral y todos los ingresos apoyan a nuestra organización sin fines de lucro.', '2025-03-04', 'Berkley', NULL, 29.00, 'misterio-thriller');