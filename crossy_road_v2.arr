use context starter2024
import image as i
import reactors as r

data Posn:
  | pos(x, y, img)
end

# Screen dimensions
height = 500
width = 800

# Images
car-url = ("https://code.pyret.org/shared-image-contents?sharedImageId=1Qr9c_bixECnBnDe7ZJRUOahIyd9CWzs4")
car1-image = scale(0.18, i.image-url(car-url))

car2-url = ("https://code.pyret.org/shared-image-contents?sharedImageId=1kfhd0hqJT9KyiJESy1oY0FBNsOIYXTHV")
car2-image = scale(0.18, i.image-url(car2-url))

bike = 
  scale(0.1, flip-horizontal(image-url("https://code.pyret.org/shared-image-contents?sharedImageId=1snoY75SUZCptv-3-Oo9YRAfmtyt42EYQ")))

g-truck = scale(0.18, flip-horizontal(image-url("https://code.pyret.org/shared-image-contents?sharedImageId=1gfutOS0ezWNa7mQeB1JtVALwkLrzZKGH")))

amb = scale(0.15, 
  image-url("https://code.pyret.org/shared-image-contents?sharedImageId=1_feqnaQccdNIr6c35iRnMRHSn-Bqup-D"))

coc-url = ("https://code.pyret.org/shared-image-contents?sharedImageId=1VOifaaydH_X8B5UrwT_6nlWBm9MSpCt9")
chicken-image = scale(0.06, i.image-url(coc-url)) 

train = scale(0.18, image-url("https://code.pyret.org/shared-image-contents?sharedImageId=1eP89ui7CPZQDcrjtBj63ztyQMWEAj_Gv"))
compart = scale(0.18, image-url("https://code.pyret.org/shared-image-contents?sharedImageId=1VYVKpBhGB3j2NcV4HYRJHgfK7SVYjDZI"))
cc = beside(compart, compart)
comp = beside(compart, cc)
ctrain = beside(comp, train)
train-image = ctrain

train-width = image-width(train-image)

# Road and tracks
rd-height = 100
road = i.rectangle(800, rd-height, "solid", "slate-grey")

r1 = image-url("https://code.pyret.org/shared-image-contents?sharedImageId=1Ci_VqvQnTG1EJbgMnDzqgFtccjoBfPhc")
rot = scale(0.15, rotate(90, r1))
fun track-rep(im :: Image) -> Image:
  if image-width(im) >= 900:
    im
  else:
    track-rep(beside(im, im))
  end
end
tracks = track-rep(rot)

# Background
blank-screen = i.rectangle(width, height, "solid", "dark-green")
backroad = i.place-image(road, (width / 2), (height * (1 / 4)), blank-screen)
background = i.place-image(road, (width / 2), (height * (3 / 4)), i.place-image(tracks, (width / 4), (height / 2), backroad))



fun random-btwn(min, max):
  num-random(max - min) + min
end

# Initial positions
init-car1-pos = pos(0, height * (3 / 4), car1-image)
init-car2-pos = pos(random-btwn(-10, -20), height * (3 / 4), car2-image)
init-bike-pos = pos(800, height * (1 / 4), bike)
init-ambu-pos = pos(random-btwn(810, 850), height * (1 / 4), amb)
init-gtruck-pos = pos(random-btwn(810, 850), height * (1 / 4), g-truck)
init-chicken-pos = pos(width / 2, height - 25, chicken-image)
init-train-pos = pos(0 - train-width, (height / 2), train-image)
init-train-timer = 6 * 28  # 6 seconds with 28 ticks per second
# Train speed
train-speed = 20

# Random car speed
const1 = random-btwn(7, 16)
const2 = random-btwn(5, 20)


fun car1-p-tick(s):
  const1 + s
end

fun car2-p-tick(s):
  const2 + s
end

fun move-left1(s):
  num-modulo(s - const1, width)
end

fun move-left2(s):
  num-modulo(s - const2, width)
end

fun move-left3(s):
  num-modulo(s - 20, width)
end



fun move-car1-wrap(t):
  num-modulo(car1-p-tick(t), width)
end

fun move-car2-wrap(t):
  num-modulo(car2-p-tick(t), width)
end

# Chicken movement functions
key-distance = 10
fun move-chicken-on-key(chicken-pos, key):
  ask:
    | (key == "up") and (chicken-pos.y > key-distance) then:
      pos(chicken-pos.x, chicken-pos.y - key-distance, chicken-image)
    | (key == "down") and (chicken-pos.y < (height - 25)) then:
      pos(chicken-pos.x, chicken-pos.y + key-distance, chicken-image)
    | key == "left" then:
      pos(chicken-pos.x - key-distance, chicken-pos.y, chicken-image)
    | key == "right" then:
      pos(chicken-pos.x + key-distance, chicken-pos.y, chicken-image)
    | otherwise: chicken-pos
  end
end

# Update train position
fun update-train-pos(train-pos, timer):
  if timer > 0:
    0 - train-width  # Train stays off-screen while timer counts down
  else if train-pos >= (width + train-width):
    0 - train-width  # Reset position after exiting screen
  else:
    train-pos + train-speed  # Move train
  end
end

# Update timer
fun update-timer(timer, train-pos):
  if timer > 0:
    timer - 1
  else if train-pos >= (width + train-width):
    7 * 28  # Reset timer after train exits
  else:
    timer  # Keep timer at 0 while train is moving
  end
end

# signal 

signal-base = i.rectangle(50, 30, "solid", "black")
signal-red = i.overlay(i.circle(10, "solid", "red"), signal-base)
signal-off = i.overlay(i.circle(10, "solid", "grey"), signal-base)

signal-x = width - 25
signal-y = (height / 2) - 60



signal-dur = 2 #starts 2 secs before train
fun signal-stat(timer):
  if timer <= signal-dur:
    signal-red
  else:
    signal-off
  end
end
 

#end condition
fun distance(p1, p2):
  fun squar(n): n * n end
  num-sqrt(squar(p1.x - p2.x) + squar(p1.y - p2.y))
end

fun are-overlapping-normal(airplane-posn, balloon-posn):
  distance(airplane-posn, balloon-posn)
    < 50
end
fun are-overlapping-train(airplane-posn, balloon-posn):
  distance(airplane-posn, balloon-posn)
    < 100
end

#game-over display
fun display-end(scene):
  d-opt = [list: "Splattered!", "Roadkill!", "Splat!", ":(", "Dead meat!"]
  picked = d-opt.get(num-random(4))
  gotxt = i.text(picked, 40, "crimson")
  tbox = rectangle(200, 100, 0.95, "dark-slate-grey")
  final = i.overlay(gotxt, tbox)
  i.place-image(final, width / 2, height / 2, scene)
end
#successful crossing
fun win(scene):
  tbox = rectangle(250, 100, 0.95, "dark-slate-grey")
  
  txt = i.text( "Road Crossed!", 40, "white")
  
  final = i.overlay(txt, tbox)
  i.place-image(final, width / 2, height / 2, scene)
end
# Drawing functions
fun draw-train(train-pos, scene):
  i.place-image(train-image, train-pos, (height / 2), scene)
end

fun draw-img(img, scene):
  i.place-image(img, signal-x, signal-y, scene)
end
fun draw-chicken(chicken-pos, scene ):
  i.place-image(chicken-image, chicken-pos.x, chicken-pos.y, scene)
end

fun to-draw-world(w):
  car1-pos = w.car1-pos.x
  car2-pos = w.car2-pos.x
  chicken-pos = w.chicken-pos
  train-pos = w.train-pos.x
  signal = signal-stat(w.train-timer)
  
  # Placing cars and road
  cars-scene = i.place-image(car2-image, car2-pos, (height * (3 / 4)), 
    i.place-image(car1-image, car1-pos, (height * (3 / 4)), background))
  
  # Placing the gtruck, bike, and ambulance at height * (1 / 4)
  moving-vehicles = i.place-image(g-truck, w.gtruck-pos.x, (height * (1 / 4)),
    i.place-image(bike, w.bike-pos.x, (height * (1 / 4)),
      i.place-image(amb, w.ambu-pos.x, (height * (1 / 4)), cars-scene)))
  
  # Drawing the train and signal
  train-scene = draw-train(train-pos, moving-vehicles)
  signal-scene = draw-img(signal, train-scene)
  
  # Drawing the chicken
  chicken-scene = draw-chicken(chicken-pos, signal-scene)
  if w.chicken-pos.y <= 10:
    win(chicken-scene)
  else if game-over(w):
    display-end(chicken-scene)
  else:
  chicken-scene
end
end


# World state
data World:
  | world(car1-pos :: Posn, car2-pos :: Posn, gtruck-pos :: Posn, bike-pos :: Posn, ambu-pos :: Posn, chicken-pos :: Posn, train-pos :: Posn, train-timer :: Number)
end

fun collision-detected(chic, obj):
  # Horizontal range: Check if chicken's x-position is within the object's width
  horizontal-range = range(
    obj.x - (image-width(obj.img) / 2), 
    obj.x + (image-width(obj.img) / 2)
  )
  
  # Vertical range: Check if chicken's y-position is within the object's height
  vertical-range = range(
    obj.y - (image-height(obj.img) / 2), 
    obj.y + (image-height(obj.img) / 2)
  )
  
  # Return true if chicken is within both ranges
  member(horizontal-range, chic.x) and member(vertical-range, chic.y)
end

fun game-over(w):
  collision-detected(w.chicken-pos, w.car1-pos) or
  collision-detected(w.chicken-pos, w.car2-pos) or
  collision-detected(w.chicken-pos, w.gtruck-pos) or
  collision-detected(w.chicken-pos, w.bike-pos) or
  collision-detected(w.chicken-pos, w.ambu-pos) or
  collision-detected(w.chicken-pos, w.train-pos)
end

fun on-tick-world(w):
  world(
    pos(move-car1-wrap(w.car1-pos.x), height * (3 / 4), car1-image),
    pos(move-car2-wrap(w.car2-pos.x),  height * (3 / 4), car2-image),
    pos(move-left1(w.gtruck-pos.x), height * (1 / 4),g-truck),
    pos(move-left2(w.bike-pos.x),  height * (1 / 4), bike),
    pos(move-left3(w.ambu-pos.x), height * (3 / 4), amb),
    w.chicken-pos,
    pos(update-train-pos(w.train-pos.x, w.train-timer), height / 2, train-image),
    update-timer(w.train-timer, w.train-pos.x)
  )
end

fun on-key-world(w, key):
  world(
    pos(w.car1-pos.x, height * (3 / 4), car1-image),
    pos(w.car2-pos.x, height * (3 / 4),  car2-image),
    pos(w.gtruck-pos.x, height * (1 / 4), g-truck),
    pos(w.bike-pos.x, height * (1 / 4), bike),
    pos(w.ambu-pos.x, height * (1 / 4), amb),
    move-chicken-on-key(w.chicken-pos, key), 
    pos(w.train-pos.x, height * (1 / 4), train-image),
    w.train-timer)
end

# Reactor setup
anim = reactor:
  init: world(init-car1-pos, init-car2-pos,init-gtruck-pos, init-bike-pos, init-ambu-pos, init-chicken-pos, init-train-pos, init-train-timer),
  on-tick: on-tick-world,
  on-key: on-key-world,
  to-draw: to-draw-world,
  stop-when: game-over
end

r.interact(anim)