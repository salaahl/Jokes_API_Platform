<?php

namespace App\Entity;

use ApiPlatform\Metadata\ApiResource;
use ApiPlatform\Metadata\Get;
use ApiPlatform\Metadata\GetCollection;
use ApiPlatform\Metadata\Post;
use ApiPlatform\Metadata\Put;
use ApiPlatform\Metadata\Delete;
use App\Repository\JokeRepository;
use Doctrine\DBAL\Types\Types;
use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;

#[ORM\Entity(repositoryClass: JokeRepository::class)]
#[ApiResource(
    normalizationContext: ['groups' => ['read']],
    order: ['id' => 'ASC']
)]
#[GetCollection]
#[Post(
    security: "is_granted('ROLE_ADMIN')",
    securityMessage: 'Désolé, vous ne disposez pas des droits nécessaires pour accomplir cette action.'
)]
#[Get]
#[Put(
    security: "is_granted('ROLE_ADMIN')",
    securityMessage: 'Désolé, vous ne disposez pas des droits nécessaires pour accomplir cette action.'
)]
#[Delete(
    security: "is_granted('ROLE_ADMIN')",
    securityMessage: 'Désolé, vous ne disposez pas des droits nécessaires pour accomplir cette action.'
)]
class Joke
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups('read')]
    private ?int $id = null;

    #[ORM\Column(type: Types::TEXT)]
    #[Groups('read')]
    private ?string $content = null;

    #[ORM\Column(length: 255)]
    #[Groups('read')]
    private ?string $answer = null;

    #[ORM\ManyToOne(inversedBy: 'jokes')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Author $author = null;

    public function __toString(): string
    {
        return $this->content;
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getContent(): ?string
    {
        return $this->content;
    }

    public function setContent(string $content): static
    {
        $this->content = $content;

        return $this;
    }

    public function getAnswer(): ?string
    {
        return $this->answer;
    }

    public function setAnswer(string $answer): static
    {
        $this->answer = $answer;

        return $this;
    }

    public function getAuthor(): ?Author
    {
        return $this->author;
    }

    public function setAuthor(?Author $author): static
    {
        $this->author = $author;

        return $this;
    }
}
