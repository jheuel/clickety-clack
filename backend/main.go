package main

import (
	"bufio"
	"log"
	"math/rand"
	"os"
	"strings"

	"github.com/gofiber/fiber/v2"
)

func pickRandomWordsWithDupes(words []string, count int) []string {
	result := make([]string, count)

	for i := 0; i < count; i++ {
		result[i] = words[rand.Intn(len(words))]
	}

	return result
}

func main() {
	app := fiber.New()
	app.Static("/", "../frontend/build")

	app.Get("/api/text", func(c *fiber.Ctx) error {
		file_name := "words.txt"
		file, err := os.Open(file_name)
		if err != nil {
			log.Fatal(err)
		}
		defer file.Close()

		scanner := bufio.NewScanner(file)
		words := []string{}
		for scanner.Scan() {
			words = append(words, scanner.Text())
		}

		return c.JSON(fiber.Map{
			"text": strings.Join(pickRandomWordsWithDupes(words, 20), " "),
		})
	})
	app.Listen(":3000")
}
