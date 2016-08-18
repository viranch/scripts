import random

class SnakesLadders:
    def __init__(self):
        self.ladders = {
            1: 38,
            4: 14,
            9: 31,
            21: 42,
            28: 84,
            36: 44,
            51: 67,
            71: 91,
            80: 100,
        }

        self.snakes = {
            16: 6,
            47: 26,
            49: 11,
            56: 53,
            62: 19,
            64: 60,
            87: 24,
            93: 73,
            95: 75,
            98: 78,
        }

    def check_ladders(self, pos):
        return self.ladders.get(pos, None)

    def check_snakes(self, pos):
        return self.snakes.get(pos, None)

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
            if up is not None:
                new = up
                print "=ladder=>", new
            else:
                down = self.snl.check_snakes(new)
                if down is not None:
                    new = down
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
