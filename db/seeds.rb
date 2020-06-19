# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'open-uri'

# ---------------------
# Creation des projets
# ---------------------

Project.destroy_all

puts "Création de projets"

p1 = Project.new(name: "All Heroes", project_type: "web developpement", description: "Site web où l'on peut retrouver les héros de son enfance et leurs caractéristiques.", url: "http://allheroes.herokuapp.com/")
project_photo = URI.open('https://res.cloudinary.com/dzububqki/image/upload/v1592306721/Portofolio/allheroes2_hzmubg.jpg')
p1.project_photo.attach(io: project_photo, filename: "All-Heroes.jpg", content_type: "image/jpg")
p1.save!

p2 = Project.new(name: "Island Booking", project_type: "web developpement", description: "Site de location d'iles paradisiaques. Venez tenter l'aventure !", url: "https://islandsbooking-olboaz.herokuapp.com/")
project_photo = URI.open('https://res.cloudinary.com/dzububqki/image/upload/v1592387360/Portofolio/island_x96jld.jpg')
p2.project_photo.attach(io: project_photo, filename: "islandbooking.jpg", content_type: "image/jpg")
p2.save!

p3 = Project.new(name: "Moods", project_type: "web developpement", description: "Creation de playlist selon son humeur sur votre compte Spotify. Réglages de Acousticness, Danceability, Energy, Positivity et Popularity afin de à votre humeur", url: "http://www.moods.best/")
project_photo = URI.open('https://res.cloudinary.com/dzububqki/image/upload/v1592387328/Portofolio/moods_rntsia.jpg')
p3.project_photo.attach(io: project_photo, filename: "moods.jpg", content_type: "image/jpg")
p3.save!

p4 = Project.new(name: "Power BI", project_type: "Data Analyse / Data visualisation", description: "Creation d'un dashboard de suivi de la performance au mois", url: "")
project_photo = URI.open('https://res.cloudinary.com/dzububqki/image/upload/v1592410108/Portofolio/PowerBI_u8w6bm.jpg')
p4.project_photo.attach(io: project_photo, filename: "moods.jpg", content_type: "image/jpg")
p4.save!

p5 = Project.new(name: "Language R", project_type: "Data Analyse - Clustering Graphes", description: "Clustering d'un réseau de match de football américain.", url: "")
project_photo = URI.open('https://res.cloudinary.com/dzububqki/image/upload/v1592564591/R_graphe_clustering_lhb2ve.jpg')
p5.project_photo.attach(io: project_photo, filename: "clusteringgraphes.jpg", content_type: "image/jpg")
p5.save!

p6 = Project.new(name: "Language R", project_type: "Data Analyse - Time Series Predictive", description: "Analyse de séries temporelles en vue de faire une analyse prédictive", url: "")
project_photo = URI.open('https://res.cloudinary.com/dzububqki/image/upload/v1592564591/R_series_temporelles_kahkdv.jpg')
p6.project_photo.attach(io: project_photo, filename: "timeseries.jpg", content_type: "image/jpg")
p6.save!

p7 = Project.new(name: "Language R", project_type: "Data Analyse - Random Forest", description: "Classification de mails entre spam et nonspam via la méthode des forets aléatoires", url: "")
project_photo = URI.open('https://res.cloudinary.com/dzububqki/image/upload/v1592564633/R_random_forest_spam_txz29u.jpg')
p7.project_photo.attach(io: project_photo, filename: "rf.jpg", content_type: "image/jpg")
p7.save!

puts "#{Project.count} projects créés !"


# ---------------------
# Creation des outils
# ---------------------


Tool.destroy_all
puts "Create all tools"

t1 = Tool.new(name: "Ruby", tool_type: "web developpement")
tool_photo = URI.open('https://res.cloudinary.com/dzububqki/image/upload/v1592245120/Portofolio/3cu7ytfglkr8sqewubjwldtrdwd6.svg')
t1.tool_photo.attach(io: tool_photo, filename: "ruby.svg", content_type: "image/svg")
t1.save!
puts "t1 créés"

t2 = Tool.new(name: "Rails", tool_type: "web developpement")
tool_photo = URI.open('https://res.cloudinary.com/dzububqki/image/upload/v1592247952/Portofolio/b765znhr1z4fbdmpm53v69j53zxz.svg')
t2.tool_photo.attach(io: tool_photo, filename: "rails.svg", content_type: "image/svg")
t2.save!
puts "t2 créés"

t3 = Tool.new(name: "Html", tool_type: "web developpement")
tool_photo = URI.open("https://res.cloudinary.com/dzububqki/image/upload/v1592334462/Portofolio/file_type_html_icon_130541_tqmrgf.png")
t3.tool_photo.attach(io: tool_photo, filename: "html.png", content_type: "image/png")
t3.save!
puts "t3 créés"

t4 = Tool.new(name: "CSS", tool_type: "web developpement")
tool_photo = URI.open('https://res.cloudinary.com/dzububqki/image/upload/v1592334568/Portofolio/file_type_css_icon_130661_y2ejrr.png')
t4.tool_photo.attach(io: tool_photo, filename: "css.png", content_type: "image/png")
t4.save!
puts "t4 créés"

t5 = Tool.new(name: "Javascript", tool_type: "web developpement")
tool_photo = URI.open('https://res.cloudinary.com/dzububqki/image/upload/v1592334677/Portofolio/javascript_icon_130900_kz44sp.png')
t5.tool_photo.attach(io: tool_photo, filename: "javascript.png", content_type: "image/png")
t5.save!
puts "t5 créés"

t6 = Tool.new(name: "Power BI", tool_type: ["data analyse", "data visualisation"])
tool_photo = URI.open('https://res.cloudinary.com/dzububqki/image/upload/v1592388982/Portofolio/powerbi_dmdswl.jpg')
t6.tool_photo.attach(io: tool_photo, filename: "powerbi.jpg", content_type: "image/jpg")
t6.save!
puts "t6 créés"

t7 = Tool.new(name: "Language R", tool_type: ["data analyse"])
tool_photo = URI.open('https://res.cloudinary.com/dzububqki/image/upload/v1592248644/Portofolio/hklyxg81nu4kdtp922vdlwnske22.png')
t7.tool_photo.attach(io: tool_photo, filename: "r.png", content_type: "image/png")
t7.save!
puts "t7 créés"

t8 = Tool.new(name: "Excel")
tool_photo = URI.open('https://res.cloudinary.com/dzububqki/image/upload/v1592417449/Portofolio/microsoft_office_excel_logo_icon_145720_xsasns.png')
t8.tool_photo.attach(io: tool_photo, filename: "excel.png", content_type: "image/png")
t8.save!
puts "t8 créés"

t9 = Tool.new(name: "PostgreSQL", tool_type: "data management")
tool_photo = URI.open('https://res.cloudinary.com/dzububqki/image/upload/v1592389470/Portofolio/postgresql_plain_logo_icon_146389_znaqof.png')
t9.tool_photo.attach(io: tool_photo, filename: "access.png", content_type: "image/png")
t9.save!
puts "t9 créés"

t10 = Tool.new(name: "Figma")
tool_photo = URI.open('https://res.cloudinary.com/dzububqki/image/upload/v1592418397/Portofolio/Figma-1-logo_m2ohxt.png')
t10.tool_photo.attach(io: tool_photo, filename: "figma.png", content_type: "image/png")
t10.save!
puts "t10 créés"

t11 = Tool.new(name: "Heroku")
tool_photo = URI.open('https://res.cloudinary.com/dzububqki/image/upload/v1592418216/Portofolio/heroku_icon_130912_gsouix.png')
t11.tool_photo.attach(io: tool_photo, filename: "heroku.png", content_type: "image/png")
t11.save!
puts "t11 créés"

t12 = Tool.new(name: "Github", tool_type: "web developpement")
tool_photo = URI.open('https://res.cloudinary.com/dzububqki/image/upload/v1592389623/Portofolio/github-logo_icon-icons.com_73546_p83hhr.png')
t12.tool_photo.attach(io: tool_photo, filename: "github.png", content_type: "image/png")
t12.save!
puts "t12 créés"

puts "#{Tool.count} Tools créés !"
