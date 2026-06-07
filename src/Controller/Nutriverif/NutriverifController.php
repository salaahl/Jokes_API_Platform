<?php

namespace App\Controller\Nutriverif;

use Psr\Log\LoggerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Contracts\HttpClient\HttpClientInterface;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\HttpFoundation\Response;

class NutriverifController extends AbstractController
{
    private HttpClientInterface $httpClient;
    private LoggerInterface $logger;

    public function __construct(HttpClientInterface $httpClient, LoggerInterface $logger)
    {
        $this->httpClient = $httpClient;
        $this->logger = $logger;
    }

    #[Route('/search-products', name: 'search_products', methods: ['POST'])]
    public function search(Request $request): JsonResponse
    {
        try {
            $data = $request->toArray();
            $url = $data['url'] ?? null;
            $method = strtoupper($data['method'] ?? 'GET');

            if (!isset($url)) {
                $this->logger->warning('NutriVerif: Tentative d\'appel sans paramètre "url".');
                return $this->json(
                    ['error' => 'Le paramètre "url" est requis.'],
                    Response::HTTP_BAD_REQUEST
                );
            }

            $response = $this->httpClient->request($method, $url, [
                'headers' => [
                    'User-Agent' => 'NutriVérif/1.0 (sokhona.salaha@gmail.com)',
                ],
            ]);

            $content = $response->getContent();
            $decoded = json_decode($content, true);

            if (json_last_error() !== JSON_ERROR_NONE) {
                $this->logger->error('NutriVerif: Réponse non-JSON', [
                    'content_preview' => substr($content, 0, 500)
                ]);
                return $this->json(
                    ['error' => 'Réponse non-JSON reçue.'],
                    Response::HTTP_BAD_GATEWAY
                );
            }

            return $this->json($decoded);

            return $this->json($response->toArray());
        } catch (\Exception $e) {
            $this->logger->critical('NutriVerif: Crash du contrôleur ! Message : ' . $e->getMessage(), [
                'exception' => $e
            ]);

            return $this->json(
                ['error' => 'Une erreur interne est survenue.', 'details' => $e->getMessage()],
                Response::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }
}
