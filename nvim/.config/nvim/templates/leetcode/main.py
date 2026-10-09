class Solution:
    def solve(self, *args):
        pass


if __name__ == "__main__":
    solution = Solution()
    while True:
        line = input()
        if not line:
            break
        args = line.split()
        print(solution.solve(*args))
