<?php

namespace App\Controller\Nutriverif;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Contracts\HttpClient\HttpClientInterface;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\HttpFoundation\Response;

class NutriverifController extends AbstractController
{
    private HttpClientInterface $httpClient;

    public function __construct(HttpClientInterface $httpClient)
    {
        $this->httpClient = $httpClient;
    }

    #[Route('/search-products', name: 'search_products', methods: ['POST'])]
    public function search(Request $request): JsonResponse
    {
        $data = $request->toArray();

        $url = $data['url'] ?? null;
        $method = strtoupper($data['method'] ?? 'GET');

        if (!isset($url)) {
            return $this->json(
                ['error' => 'Le paramètre "url" est requis.'],
                Response::HTTP_BAD_REQUEST
            );
        }

        $response = $this->httpClient->request($method, $url, [
            'headers' => [
                'User-Agent' => 'NutriVérif/1.0 (sokhona.salaha@gmail.com)',
            ],
        ]);

        if (200 !== $response->getStatusCode()) {
            return $this->json(
                ['error' => 'Erreur lors de l’appel à OpenFoodFacts.', 'status' => $response->getStatusCode()],
                Response::HTTP_BAD_GATEWAY
            );
        }

        return $this->json($response->toArray());
    }
}
