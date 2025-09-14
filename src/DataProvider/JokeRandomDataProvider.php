<?php

namespace App\DataProvider;

use ApiPlatform\Doctrine\Orm\Paginator as ApiPaginator;
use ApiPlatform\Metadata\Operation;
use ApiPlatform\State\ProviderInterface;
use App\Entity\Joke;
use Doctrine\ORM\EntityManagerInterface;
use Doctrine\ORM\Tools\Pagination\Paginator as ORMPaginator;

class JokeRandomDataProvider implements ProviderInterface
{
    public function __construct(private EntityManagerInterface $em) {}

    public function provide(Operation $operation, array $uriVariables = [], array $context = []): ApiPaginator
    {
        $page = $context['pagination']['page'] ?? 1;
        $itemsPerPage = $context['pagination']['items_per_page'] ?? 10;

        $qb = $this->em->getRepository(Joke::class)
            ->createQueryBuilder('j')
            ->orderBy('RAND()')
            ->setFirstResult(($page - 1) * $itemsPerPage)
            ->setMaxResults($itemsPerPage);

        return new ApiPaginator(new ORMPaginator($qb));
    }
}
