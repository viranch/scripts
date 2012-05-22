import random

class Map:
    def __init__(self):
        self.map_from = []
        self.map_to = []
    def append(self, key, value):
        self.map_from.append(key)
        self.map_to.append(value)
    def value(self, key):
        return self.map_to[self.map_from.index(key)]
    def key(self, value):
        return self.map_from[self.map_to.index(key)]
    def keys(self):
        return self.map_from
    def values(self):
        return self.map_to

class SnakesLadders:
    def __init__(self):
        self.ladders = Map()
        self.ladders.append(1, 38)
        self.ladders.append(4, 14)
        self.ladders.append(9, 31)
        self.ladders.append(21, 42)
        self.ladders.append(28, 84)
        self.ladders.append(36, 44)
        self.ladders.append(51, 67)
        self.ladders.append(71, 91)
        self.ladders.append(80, 100)

        self.snakes = Map()
        self.snakes.append(16, 6)
        self.snakes.append(47, 26)
        self.snakes.append(49, 11)
        self.snakes.append(56, 53)
        self.snakes.append(62, 19)
        self.snakes.append(64, 60)
        self.snakes.append(87, 24)
        self.snakes.append(93, 73)
        self.snakes.append(95, 75)
        self.snakes.append(98, 78)

    def check_ladders(self, pos):
        final = pos
        if pos in self.ladders.keys(): final = self.ladders.value(pos)
        return (final, pos!=final)

    def check_snakes(self, pos):
        final = pos
        if pos in self.snakes.keys(): final = self.snakes.value(pos)
        return (final, pos!=final)

class World:
    def __init__(self):
        self.pos = [0, 0]
        self.names = []
        self.names.append(raw_input("Enter first player's name: "))
        self.names.append(raw_input("Enter another player's name: "))
        self.snl = SnakesLadders()

    def roll_dice(self):
        random.seed()
        return random.randint(1, 6)

    def first(self):
        player = 0
        while self.roll_dice()!=6: player = 1-player
        return player

    def play(self, pos, dice):
        final = pos + dice
        if final > 100: return pos
        return final

    def startGame(self):
        turn = self.first()
        print self.names[turn], "will go first"
        count = True
        while True:
            raw_input()
            dice = self.roll_dice()
            new = self.play(self.pos[turn], dice)
            print self.names[turn], ":", self.pos[turn], "="+str(dice)+"=>", new,

            up = self.snl.check_ladders(new)
            if up[1]:
                new = up[0]
                print "=ladder=>", new
            else:
                down = self.snl.check_snakes(new)
                if down[1]:
                    new = down[0]
                    print "=snake=>", new
                else:
                    print ""

            self.pos[turn] = new
            if self.pos[turn] == 100:
                print self.names[turn], "wins!"
                break
            if dice<6:
                turn = 1-turn
                count = not count
                if count: print ""
            else:
                print self.names[turn], "will play again"

w = World()
w.startGame()
