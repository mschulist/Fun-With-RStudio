#This is the beginning of my R coding experience
#I am going to try to use eBird data and the library "auk" to interpret eBird data
#My end goal is to create a map of Yellow-rumped Warbler distribution in Montgomery County, Alabama
#This is where the all of the data for the eBird sample is from
#After learning how to sort through the eBird data and filter by species, I will learn how to use Shiny
#I will take the coords of each sighting that I sorted and then overlay them on a map of Montgomery County
#I will try to make the process as simple as possible and take tons of notes of what I am doing
#I will also mess up a lot and try to document when I mess up and what mistake to not make
#I will try to make this as easy to transfer to the entire (or part) of the eBird data set
#This will make it easy for me (and anyone else) to reuse this code for other projects

#I will begin by installing every possible package that I see necessary
#I will probably continue to add more as I go on.
#Let's start by installing and adding the necessary packages

install.packages("auk")
install.packages("tidyverse")
install.packages("shiny")
install.packages("rnaturalearth")
install.packages("sf")
install.packages("rnaturalearthhires", repos = "http://packages.ropensci.org", type = "source")
install.packages("rgeos")

#You don't necessarily need to install the packages if you already have them, but I believe
#that it will just see that you already have it but I am really not sure
#You definitely need to add them to the library so that you can use them

library("auk")
library("tidyverse")
library("shiny")
library("rnaturalearth")
library("sf")
library("rnaturalearthhires")
library("rgeos")

#I am going to create an object for the file directory as I believe that we are going to use it a lot
#The object will be called "sdata" which is short for "sample data"

sdata <- "Ebird_Data/ebd-data.txt"

#This will allow us to just put "sdata" in place of the file
#I could use "x" or something short, but that would become annoying in the future if you wanted to use 
#multiple data sets, like data sets from a study and also eBird

#Similar to in the README in the AUK github page, I am going to use the object "f_in" for the input
#and "f_out for the output

#This creates an object for the input - makes it easier to write
f_in <- "Ebird_Data/ebd-data.txt"

#This creates an object for the output and where to put the new data ***I have put it into an excel to see what the problem is***
f_out <- "Ebird_Data/YRWA-Outputs.txt"

#This (I believe) makes the data in the original eBird .txt file in the correct form for the functions
p_data <- auk_ebd(f_in)

#This creates an object that includes what the filters are for - they are for species in this case
#The filter is for YRWA and from the p_data data set, which is the formatted f_in data set
sp_filters <- auk_species(p_data, species = "Yellow-rumped Warbler")

#This creates an object that includes the filter (species), what file to filter from, and where the output is
#I put "overwrite" in there so that I am able to do it multiple times to the same output
#You would probably want to change the overwrite for a final project to make sure that your data is kept safe
sp_filtered <- auk_filter(sp_filters, file = f_out, overwrite = TRUE)

#This finally takes all of the filters and reads them onto the output, this supposedly takes a lot of time 
#with the full data set FYI (for your information)
ebd_df <- read_ebd(sp_filtered)

#After much struggle, I am finally able to sort the data with these 6 lines of code!!!
#The main problem was that due me being on a Windows PC, it does not natively have UNIX
#AUK requires UNIX so I had to download Cygwin (https://www.cygwin.com/) to allow AUK to run
#We have successfully created an output file that now only includes the YRWA sightings

ebd <- read_ebd(f_out)

#Now that we have only YRWA in the output, we can read it into any normal plotting program

#This plotting program uses a package (rnaturalearth) to plot points on a map of the earth
#I have taken most of this code from (https://ropensci.org/blog/2018/08/07/auk/), thanks for the great tutorial!

#Converting the data to a spatial object

ebd_sf <- ebd %>%
  select(common_name, latitude, longitude) %>%
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

# getting state map using rnaturalearth package

states <- ne_states(iso_a2 = c("US", "CA"), returnclass = "sf")
Al <- filter(states, postal == "AL") %>%
  st_geometry()

#map part

par(mar = c(0,0,0,0), bg = "skyblue")

#plot extent

plot(Al, col = NA)

#add state boundaries

plot(states %>% st_geometry(), col = "grey40", border = "white", add = TRUE)
plot(Al, col = "grey20", border = "white", add = TRUE)

#eBird data

plot(ebd_sf %>% filter(common_name == "Yellow-rumped Warbler") %>% st_geometry(), 
     col = "#377eb899", pch = 19, cex = 0.75, add = TRUE)
