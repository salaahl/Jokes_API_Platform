<?php

namespace App\Entity;


use ApiPlatform\Metadata\ApiResource;
use ApiPlatform\Metadata\Get;
use ApiPlatform\Metadata\GetCollection;
use ApiPlatform\Metadata\Post;
use ApiPlatform\Metadata\Put;
use ApiPlatform\Metadata\Delete;
use App\Repository\AuthorRepository;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;

#[ORM\Entity(repositoryClass: AuthorRepository::class)]
#[ApiResource(
    normalizationContext: ['groups' => ['author:read']],
    order: ['name' => 'ASC']
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
class Author
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups('author:read')]
    private ?int $id = null;

    #[Groups('author:read, joke:read')]
    #[ORM\Column(length: 255)]
    private ?string $name = null;

    /**
     * @var Collection<int, Joke>
     */
    #[ORM\OneToMany(targetEntity: Joke::class, mappedBy: 'author', orphanRemoval: true)]
    #[Groups('author:full')]
    private Collection $jokes;

    public function __construct()
    {
        $this->jokes = new ArrayCollection();
    }

    public function __toString(): string
    {
        return $this->name;
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getName(): ?string
    {
        return $this->name;
    }

    public function setName(string $name): static
    {
        $this->name = $name;

        return $this;
    }

    /**
     * @return Collection<int, Joke>
     */
    public function getJokes(): Collection
    {
        return $this->jokes;
    }

    public function addJoke(Joke $joke): static
    {
        if (!$this->jokes->contains($joke)) {
            $this->jokes->add($joke);
            $joke->setAuthor($this);
        }

        return $this;
    }

    public function removeJoke(Joke $joke): static
    {
        if ($this->jokes->removeElement($joke)) {
            // set the owning side to null (unless already changed)
            if ($joke->getAuthor() === $this) {
                $joke->setAuthor(null);
            }
        }

        return $this;
    }
}
